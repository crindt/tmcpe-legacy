
DROP TABLE IF EXISTS Person;
CREATE TABLE Person (
  id int(10) unsigned NOT NULL auto_increment,
  firstName varchar(45) NOT NULL,
  lastName varchar(45) NOT NULL,
  PRIMARY KEY  (id)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS Tiddler;
CREATE TABLE Tiddler (
  id int(10) unsigned NOT NULL auto_increment,
  name varchar(45) NOT NULL,
  modifier varchar(45),
  modified TIMESTAMP,
  created TIMESTAMP,
  data varchar(256),
  PRIMARY KEY  (id)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS Tag;
CREATE TABLE Tag (
  id int(10) unsigned NOT NULL auto_increment,
  name varchar(45) NOT NULL,
  PRIMARY KEY  (id)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
