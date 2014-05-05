--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: favourites; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favourites (
    id integer NOT NULL,
    artist character varying(255),
    title character varying(255),
    album character varying(255),
    user_id integer,
    track_ids hstore,
    search_vector tsvector,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: favourites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favourites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: favourites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favourites_id_seq OWNED BY favourites.id;


--
-- Name: playlists; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE playlists (
    id integer NOT NULL,
    name character varying(255),
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: playlists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE playlists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: playlists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE playlists_id_seq OWNED BY playlists.id;


--
-- Name: playlists_tracks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE playlists_tracks (
    playlist_id integer,
    track_id integer,
    "position" integer DEFAULT 0,
    id integer NOT NULL
);


--
-- Name: playlists_tracks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE playlists_tracks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: playlists_tracks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE playlists_tracks_id_seq OWNED BY playlists_tracks.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: sources; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sources (
    id integer NOT NULL,
    activated boolean DEFAULT false,
    processed boolean DEFAULT false,
    name character varying(255),
    configuration hstore,
    type character varying(255),
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sources_id_seq OWNED BY sources.id;


--
-- Name: tracks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tracks (
    id integer NOT NULL,
    artist character varying(255),
    title character varying(255),
    album character varying(255),
    genre character varying(255),
    tracknr integer DEFAULT 0,
    year integer,
    filename character varying(255),
    location character varying(255),
    url character varying(255),
    source_id integer,
    favourite_id integer,
    search_vector tsvector,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tracks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tracks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tracks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tracks_id_seq OWNED BY tracks.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    crypted_password character varying(255),
    salt character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    remember_me_token character varying(255) DEFAULT NULL::character varying,
    remember_me_token_expires_at timestamp without time zone,
    settings hstore
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favourites ALTER COLUMN id SET DEFAULT nextval('favourites_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY playlists ALTER COLUMN id SET DEFAULT nextval('playlists_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY playlists_tracks ALTER COLUMN id SET DEFAULT nextval('playlists_tracks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sources ALTER COLUMN id SET DEFAULT nextval('sources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tracks ALTER COLUMN id SET DEFAULT nextval('tracks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: favourites_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favourites
    ADD CONSTRAINT favourites_pkey PRIMARY KEY (id);


--
-- Name: playlists_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY playlists
    ADD CONSTRAINT playlists_pkey PRIMARY KEY (id);


--
-- Name: playlists_tracks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY playlists_tracks
    ADD CONSTRAINT playlists_tracks_pkey PRIMARY KEY (id);


--
-- Name: sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sources
    ADD CONSTRAINT sources_pkey PRIMARY KEY (id);


--
-- Name: tracks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tracks
    ADD CONSTRAINT tracks_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: favourites_default_lookup_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX favourites_default_lookup_index ON favourites USING btree (id, user_id);


--
-- Name: favourites_gin_track_ids; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX favourites_gin_track_ids ON favourites USING gin (track_ids);


--
-- Name: favourites_search_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX favourites_search_index ON favourites USING gin (search_vector);


--
-- Name: favourites_sorting_album_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX favourites_sorting_album_index ON favourites USING btree (lower((album)::text), lower((artist)::text), lower((title)::text));


--
-- Name: favourites_sorting_default_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX favourites_sorting_default_index ON favourites USING btree (lower((artist)::text), lower((album)::text), lower((title)::text));


--
-- Name: favourites_sorting_title_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX favourites_sorting_title_index ON favourites USING btree (lower((title)::text), lower((artist)::text), lower((album)::text));


--
-- Name: index_favourites_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favourites_on_user_id ON favourites USING btree (user_id);


--
-- Name: index_playlists_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_playlists_on_user_id ON playlists USING btree (user_id);


--
-- Name: index_playlists_tracks_on_playlist_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_playlists_tracks_on_playlist_id ON playlists_tracks USING btree (playlist_id);


--
-- Name: index_playlists_tracks_on_track_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_playlists_tracks_on_track_id ON playlists_tracks USING btree (track_id);


--
-- Name: index_sources_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sources_on_user_id ON sources USING btree (user_id);


--
-- Name: index_tracks_on_favourite_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tracks_on_favourite_id ON tracks USING btree (favourite_id);


--
-- Name: index_tracks_on_source_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tracks_on_source_id ON tracks USING btree (source_id);


--
-- Name: index_users_on_remember_me_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_remember_me_token ON users USING btree (remember_me_token);


--
-- Name: sources_gin_configuration; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX sources_gin_configuration ON sources USING gin (configuration);


--
-- Name: tracks_default_lookup_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tracks_default_lookup_index ON tracks USING btree (id, source_id);


--
-- Name: tracks_search_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tracks_search_index ON tracks USING gin (search_vector);


--
-- Name: tracks_sorting_album_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tracks_sorting_album_index ON tracks USING btree (lower((album)::text), tracknr, lower((artist)::text), lower((title)::text));


--
-- Name: tracks_sorting_default_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tracks_sorting_default_index ON tracks USING btree (lower((artist)::text), lower((album)::text), tracknr, lower((title)::text));


--
-- Name: tracks_sorting_title_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tracks_sorting_title_index ON tracks USING btree (lower((title)::text), tracknr, lower((artist)::text), lower((album)::text));


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: users_gin_settings; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX users_gin_settings ON users USING gin (settings);


--
-- Name: favourites_vector_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER favourites_vector_update BEFORE INSERT OR UPDATE ON favourites FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('search_vector', 'pg_catalog.english', 'artist', 'title', 'album');


--
-- Name: tracks_vector_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tracks_vector_update BEFORE INSERT OR UPDATE ON tracks FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('search_vector', 'pg_catalog.english', 'artist', 'title', 'album');


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20120712000000');

INSERT INTO schema_migrations (version) VALUES ('20120712202613');

INSERT INTO schema_migrations (version) VALUES ('20120714185032');

INSERT INTO schema_migrations (version) VALUES ('20120714195918');

INSERT INTO schema_migrations (version) VALUES ('20120714200814');

INSERT INTO schema_migrations (version) VALUES ('20120714202127');

INSERT INTO schema_migrations (version) VALUES ('20121115212612');

INSERT INTO schema_migrations (version) VALUES ('20130210111909');

INSERT INTO schema_migrations (version) VALUES ('20130210114740');

INSERT INTO schema_migrations (version) VALUES ('20130210122335');

INSERT INTO schema_migrations (version) VALUES ('20130415192126');

INSERT INTO schema_migrations (version) VALUES ('20130509125536');

INSERT INTO schema_migrations (version) VALUES ('20131019180939');