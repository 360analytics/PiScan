
-- Additional Tables for the POD database:
-- used to track user contributions to the core POD data

-- n.b. this schema uses uuid as binary for the primary keys,
-- since mysql's support for varchar/strings as primaty keys
-- is poor compared to binary fields
-- source: http://stackoverflow.com/a/10951183


-- Product information

-- `barcode` supplements the GTIN table via user contributions

-- It is composed of: the barcode (gtin_cd), a product name,
-- and a brand name, and, if can be confirmed, the brand's
-- bsin code (any more information via individual user
-- contribution is unlikely/unexpected)

CREATE TABLE barcode (
	id           binary(16) primary key NOT NULL,
	barcode      varchar(13) NOT NULL,     -- corresponds to GTIN.GTIN_CD
	product_name varchar(512) NOT NULL,    -- corresponds to GTIN.GTIN_NM
	product_desc varchar(512),             -- additional description (if any, optional)
	is_edit      boolean DEFAULT false, -- if this represents a correction vs a new addition to GTIN
	posted       datetime, -- automatically filled in by trigger, below
	account_id   binary(16) REFERENCES account(id)
); 

CREATE TRIGGER barcode_on_insert BEFORE INSERT ON `barcode`
    FOR EACH ROW SET NEW.posted = IFNULL(NEW.posted, NOW());

-- `contributed_brand` is for user-contributed brands which do not already
-- exist in the BRAND table of the POD database

CREATE TABLE contributed_brand (
	id         binary(16) primary key NOT NULL,
	brand_name varchar(512) NOT NULL, -- corresponds to BRAND.BRAND_NM
	brand_url  varchar(512),          -- corresponds to BRAND.BRAND_LINK
	posted     datetime, -- automatically filled in by trigger, below
	account_id binary(16) REFERENCES account(id)
);

CREATE TRIGGER contributed_brand_on_insert BEFORE INSERT ON `contributed_brand`
    FOR EACH ROW SET NEW.posted = IFNULL(NEW.posted, NOW());

-- `barcode_brand` associates user-contributed barcode information with
-- the corresponding product brand, when the brand already exists in the
-- BRAND table of the POD database

CREATE TABLE barcode_brand (
	id         binary(16) primary key NOT NULL,
	bsin       varchar(6) NOT NULL, -- corresponds to BRAND.BSIN
	barcode_id binary(16) REFERENCES barcode(id)
);

