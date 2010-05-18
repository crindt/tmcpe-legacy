DROP TABLE IF EXISTS actlog.icad CASCADE;
CREATE TABLE actlog.icad (
       KeyField INTEGER NOT NULL PRIMARY KEY,
       LogId varchar(40) NOT NULL,
       LogTime varchar(80) DEFAULT NULL,
       LogType varchar(240) DEFAULT NULL,
       Location varchar(240) DEFAULT NULL,
       Area varchar(240) DEFAULT NULL,
       ThomasBrothers varchar(80) DEFAULT NULL,
       TBXY varchar(40) DEFAULT NULL,
       D12Cad varchar(80) DEFAULT NULL,
       D12CadAlt varchar(80) DEFAULT NULL
       --- , postgis location
       );
CREATE INDEX idx_icad_d12cad ON actlog.icad( d12cad );
CREATE INDEX idx_icad_d12cadalt ON actlog.icad( d12cadalt );

DROP TABLE IF EXISTS actlog.icad_detail CASCADE;
CREATE TABLE actlog.icad_detail (
       KeyField SERIAL NOT NULL PRIMARY KEY ,
       iCAD INTEGER NOT NULL REFERENCES actlog.icad( KeyField ),
       stamp timestamp NOT NULL,
       detail varchar( 1024 )
       );
       