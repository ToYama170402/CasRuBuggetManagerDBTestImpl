create table groups (id serial primary key, name text not null unique);

create type member_role as enum(
  'group_reader',
  'accounter',
  'club_reader',
  'administrater'
);

create table users (
  id serial primary key,
  discord_id text not null,
  role member_role not null
);

create type bugget_application_state as enum(
  'checking',
  'accepted',
  'denied',
  'cancelized_acception'
);

create table bugget_application (
  id serial primary key,
  accounting_year int not null,
  group_id int not null,
  user_id int not null,
  is_income bool not null,
  name text not null,
  amount int not null,
  basis_for_application bytea,
  created_at timestamp with time zone not null default current_timestamp,
  foreign key (user_id) references users (id),
  foreign key (group_id) references groups (id)
);

create table bugget_application_state_history (
  id serial primary key,
  bugget_application int not null,
  state bugget_application_state not null,
  created_at timestamp with time zone not null default current_timestamp,
  foreign key (bugget_application) references bugget_application (id)
);

create or replace function insert_initial_bugget_state () returns trigger language plpgsql as $$
begin
insert into
  bugget_application_state_history (bugget_application, state)
values
  (new.id, 'checking');

return new;

end;

$$;

create trigger trg_insert_initial_bugget_state
after insert on bugget_application for each row
execute function insert_initial_bugget_state ();

