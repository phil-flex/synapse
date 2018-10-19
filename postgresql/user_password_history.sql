--drop table public.user_password_history;

--drop SEQUENCE public.user_password_history_id_seq;

CREATE TABLE public.user_password_history (
    id int NOT NULL PRIMARY KEY,
    name text NULL,
    old_password_hash text NULL,
    new_password_hash text NULL,
    changed_on timestamp(6) NULL
);

CREATE SEQUENCE public.user_password_history_id_seq START 1;

ALTER TABLE public.user_password_history
    ALTER COLUMN id SET DEFAULT nextval('user_password_history_id_seq');

ALTER SEQUENCE public.user_password_history_id_seq OWNED BY public.user_password_history.id;

ALTER TABLE public.user_password_history OWNER TO matrix;
GRANT ALL ON TABLE public.user_password_history TO matrix;


CREATE OR REPLACE FUNCTION public.log_user_password_changes()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
begin
IF COALESCE(NEW.password_hash, '') <> COALESCE(OLD.password_hash) THEN
 	INSERT INTO user_password_history(name,old_password_hash, new_password_hash,changed_on)
 	VALUES(NEW.name,OLD.password_hash,new.password_hash,now());
 END IF;
 RETURN NEW;
end;
 $function$

CREATE TRIGGER users_password_changes
  BEFORE UPDATE
  ON users
  FOR EACH ROW
  EXECUTE PROCEDURE log_user_password_changes();