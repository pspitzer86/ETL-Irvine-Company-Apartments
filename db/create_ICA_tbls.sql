-- Exported from QuickDBD: https://www.quickdatabasediagrams.com/
-- Link to schema: https://app.quickdatabasediagrams.com/#/d/zSP7MZ
-- NOTE! If you have used non-SQL datatypes in your design, you will have to change these here.


CREATE TABLE "apartments" (
    "apartment_id" serial   NOT NULL,
    "complex_id" integer   NOT NULL,
    "unit_id" varchar   NOT NULL,
    "sq_ft" varchar   NOT NULL,
    "plan_name" varchar   NOT NULL,
    "apt_type" varchar   NOT NULL,
    "start_price" integer   NOT NULL,
    "vacant" boolean   NOT NULL,
    "curr_price" integer   NOT NULL,
    "list_start_date" date   NOT NULL,
    "available_date" date   NOT NULL,
    "curr_date" date   NOT NULL,
    CONSTRAINT "pk_apartments" PRIMARY KEY (
        "apartment_id"
     )
);

CREATE TABLE "complex" (
    "complex_id" serial   NOT NULL,
    "complex_name" varchar   NOT NULL,
    "complex_address" varchar   NOT NULL,
    "complex_url" varchar   NOT NULL,
    "city_id" integer   NOT NULL,
    CONSTRAINT "pk_complex" PRIMARY KEY (
        "complex_id"
     )
);

CREATE TABLE "cities" (
    "city_id" serial   NOT NULL,
    "city_name" varchar   NOT NULL,
    "population" integer   NOT NULL,
    "cost_of_living" float   NOT NULL,
    "median_income" float   NOT NULL,
    "median_age" float   NOT NULL,
    CONSTRAINT "pk_cities" PRIMARY KEY (
        "city_id"
     )
);

CREATE TABLE "avg_rent" (
    "rec_id" serial   NOT NULL,
    "city_id" integer   NOT NULL,
    "apt_type" varchar   NOT NULL,
    "avg_rent" float   NOT NULL,
    CONSTRAINT "pk_avg_rent" PRIMARY KEY (
        "rec_id","city_id","apt_type"
     )
);

ALTER TABLE "apartments" ADD CONSTRAINT "fk_apartments_complex_id" FOREIGN KEY("complex_id")
REFERENCES "complex" ("complex_id");

ALTER TABLE "complex" ADD CONSTRAINT "fk_complex_city_id" FOREIGN KEY("city_id")
REFERENCES "cities" ("city_id");

ALTER TABLE "avg_rent" ADD CONSTRAINT "fk_avg_rent_city_id" FOREIGN KEY("city_id")
REFERENCES "cities" ("city_id");

