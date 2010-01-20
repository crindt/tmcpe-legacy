
DROP TABLE IF EXISTS testbed_facilities CASCADE;
CREATE TABLE testbed_facilities (
       tfid SERIAL PRIMARY KEY,
       net TEXT,
       ref TEXT,
       dir TEXT,
       rteid INTEGER
);

INSERT INTO testbed_facilities (net,ref,dir) VALUES 
       ( 'US:CA', '2', '1' ),
       ( 'US:CA', '2', '2' ),
       ( 'US:I', '5', '1' ),
       ( 'US:I', '5', '2' ),
       ( 'US:CA', '14', '1' ),
       ( 'US:CA', '14', '2' ),
       ( 'US:CA', '118', '1' ),
       ( 'US:CA', '118', '2' ),
       ( 'US:I', '210', '1' ),
       ( 'US:I', '210', '2' ),
       ( 'US:I', '105', '1' ),
       ( 'US:I', '105', '2' ),
       ( 'US:I', '405', '1' ),
       ( 'US:I', '405', '2' ),
       ( 'US:I', '605', '1' ),
       ( 'US:I', '605', '2' ),
       ( 'US:I', '710', '1' ),
       ( 'US:I', '710', '2' ),
       ( 'US:CA', '133', '1' ),
       ( 'US:CA', '133', '2' ),
       ( 'US:CA', '134', '1' ),
       ( 'US:CA', '134', '2' ),
       ( 'US:CA', '73', '1' ),
       ( 'US:CA', '73', '2' ),
       ( 'US:CA', '241', '1' ),
       ( 'US:CA', '241', '2' ),
       ( 'US:CA', '261', '1' ),
       ( 'US:CA', '261', '2' ),
       ( 'US:CA', '55', '1' ),
       ( 'US:CA', '55', '2' ),
       ( 'US:CA', '57', '1' ),
       ( 'US:CA', '57', '2' ),
       ( 'US:CA', '91', '1' ),
       ( 'US:CA', '91', '2' ),
       ( 'US:CA', '71', '1' ),
       ( 'US:CA', '71', '2' ),
       ( 'US:CA', '22', '1' ),
       ( 'US:CA', '22', '2' ),
       ( 'US:CA', '56', '1' ),
       ( 'US:CA', '56', '2' ),
       ( 'US:CA', '52', '1' ),
       ( 'US:CA', '54', '2' ),
       ( 'US:CA', '54', '1' ),
       ( 'US:CA', '52', '2' ),
       ( 'US:CA', '78', '1' ),
       ( 'US:CA', '78', '2' ),
       ( 'US:CA', '76', '1' ),
       ( 'US:CA', '76', '2' ),
       ( 'US:CA', '163', '1' ),
       ( 'US:CA', '163', '2' ),
       ( 'US:CA', '125', '1' ),
       ( 'US:CA', '125', '2' ),
       ( 'US:I', '805', '1' ),
       ( 'US:I', '805', '2' ),
       ( 'US:I', '15', '1' ),
       ( 'US:I', '15', '2' ),
       ( 'US:I', '215', '1' ),
       ( 'US:I', '215', '2' ),
       ( 'US:I', '10', '1' ),
       ( 'US:I', '10', '2' ),
       ( 'US:CA', '60', '1' ),
       ( 'US:CA', '60', '2' ),
       ( 'US:I', '8', '1' ),
       ( 'US:I', '8', '2' ),
       ( 'US', '101', '1' ),
       ( 'US', '101', '2' ),
       -- bay area
       ( 'US:I', '80', '1' ),
       ( 'US:I', '80', '2' ),
       ( 'US:I', '205', '1' ),
       ( 'US:I', '205', '2' ),
       ( 'US:I', '238', '1' ),
       ( 'US:I', '238', '2' ),
       ( 'US:I', '280', '1' ),
       ( 'US:I', '280', '2' ),
       ( 'US:I', '380', '1' ),
       ( 'US:I', '380', '2' ),
       ( 'US:I', '505', '1' ),
       ( 'US:I', '505', '2' ),
       ( 'US:I', '580', '1' ),
       ( 'US:I', '580', '2' ),
       ( 'US:I', '680', '1' ),
       ( 'US:I', '680', '2' ),
       ( 'US:I', '780', '1' ),
       ( 'US:I', '780', '2' ),
       ( 'US:I', '880', '1' ),
       ( 'US:I', '880', '2' ),
       ( 'US:I', '980', '1' ),
       ( 'US:I', '980', '2' ),
       ( 'US:CA', '1', '1' ),
       ( 'US:CA', '1', '2' ),
       ( 'US:CA', '4', '1' ),
       ( 'US:CA', '4', '2' ),
       ( 'US:CA', '12', '1' ),
       ( 'US:CA', '12', '2' ),
       ( 'US:CA', '13', '1' ),
       ( 'US:CA', '13', '2' ),
       ( 'US:CA', '17', '1' ),
       ( 'US:CA', '17', '2' ),
       ( 'US:CA', '24', '1' ),
       ( 'US:CA', '24', '2' ),
       ( 'US:CA', '29', '1' ),
       ( 'US:CA', '29', '2' ),
       ( 'US:CA', '37', '1' ),
       ( 'US:CA', '37', '2' ),
       ( 'US:CA', '77', '1' ),
       ( 'US:CA', '77', '2' ),
       ( 'US:CA', '84', '1' ),
       ( 'US:CA', '84', '2' ),
       ( 'US:CA', '85', '1' ),
       ( 'US:CA', '85', '2' ),
       ( 'US:CA', '90', '1' ),
       ( 'US:CA', '90', '2' ),
       ( 'US:CA', '92', '1' ),
       ( 'US:CA', '92', '2' ),
       ( 'US:CA', '113', '1' ),
       ( 'US:CA', '113', '2' ),
       ( 'US:CA', '160', '1' ),
       ( 'US:CA', '170', '2' ),
       ( 'US:CA', '237', '1' ),
       ( 'US:CA', '237', '2' ),
       ( 'US:CA', '242', '1' ),
       ( 'US:CA', '242', '2' ),
       ( 'US:CA', '262', '1' ),
       ( 'US:CA', '262', '2' ),
       ( 'US:CA', '23', '1' ),
       ( 'US:CA', '23', '2' ),
       ( 'US:CA', '99', '1' ),
       ( 'US:CA', '99', '2' )
       ;

DROP VIEW IF EXISTS ff CASCADE;
CREATE VIEW ff AS
SELECT freeway_id,freeway_dir,COUNT(*) as cc 
       FROM temp_vds_data 
       WHERE vdstype='ML'
       GROUP BY freeway_id,freeway_dir;


--- OK, this grabs the top two directions for each freeway_id,
--- from the vds table, which presumably are the correct ones.  
--- Ideally the vds table would only have two directions for each
--- freeway_id, but some have more (like CA 22).
DROP VIEW IF EXISTS freeway_directions CASCADE;
CREATE VIEW freeway_directions AS
SELECT f.* 
FROM 
       (
       SELECT DISTINCT freeway_id
       FROM ff
       ) lo, ff f
--- A hack to select unqiue freeway_id/freeway_dir field
WHERE  f.freeway_id||':'||f.freeway_dir in (
       SELECT freeway_id||':'||freeway_dir 
       FROM   ff ff2
       WHERE  ff2.freeway_id = lo.freeway_id
       ORDER BY
	      freeway_id,freeway_dir,cc DESC
       LIMIT 2
       );



--- compute directions from the sensor table
UPDATE testbed_facilities
       SET dir=freeway_dir
       FROM freeway_directions fd
       WHERE ref=freeway_id 
       	     AND ( ( dir='1' AND ( fd.freeway_dir in ('N', 'E') ) )
	           OR ( dir='2' AND ( fd.freeway_dir in ( 'S', 'W' ) ) ) );
