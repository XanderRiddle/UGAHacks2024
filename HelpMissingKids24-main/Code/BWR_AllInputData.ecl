﻿
IMPORT $;
IMPORT std;
HMK := $.File_AllData;

//OUTPUT(HMK.unemp_ratesDS,NAMED('US_UnempByMonth'));
//OUTPUT(CHOOSEN(HMK.unemp_byCountyDS,3000),NAMED('Unemployment'));

//OUTPUT(HMK.EducationDS,NAMED('Education'));
//OUTPUT(HMK.pov_estimatesDS,NAMED('Poverty'));
//OUTPUT(HMK.EducationDS,NAMED('Education'));
//OUTPUT(HMK.pov_estimatesDS,NAMED('Poverty'));
//OUTPUT(HMK.pop_estimatesDS,NAMED('Population'));
//OUTPUT(HMK.PoliceDS,NAMED('Police'));
//OUTPUT(HMK.FireDS,NAMED('Fire'));
//OUTPUT(HMK.HospitalDS,NAMED('Hospitals'));
//OUTPUT(HMK.ChurchDS,NAMED('Churches'));
//OUTPUT(HMK.FoodBankDS,NAMED('FoodBanks'));
//OUTPUT(CHOOSEN(HMK.mc_byStateDS,3500),NAMED('NCMEC'));
//OUTPUT(COUNT(HMK.mc_byStateDS),NAMED('NCMEC_Cnt'));
//OUTPUT(HMK.City_DS,NAMED('Cities'));
//OUTPUT(COUNT(HMK.City_DS),NAMED('Cities_Cnt'));
//OUTPUT(HMK.unemp_byCountyDS(Attribute = 'Unemployment_rate_2022'),NAMED('Ri'));
//OUTPUT(JOIN(HMK.mc_byStateDS, HMK.City_DS, LEFT.missingcity = RIGHT.city AND LEFT.missingstate = RIGHT.state_id),NAMED('Joined_Unemployment_County_Fips'));

County_Fips_Of_Missing_Children_Record := RECORD 
  STRING county_fips;
END;


County_Fips_Of_Missing_Children_Record County_Fips_Transform(HMK.mc_byStateDS Le,HMK.City_DS Ri) := TRANSFORM
    SELF.county_fips := (STRING)Ri.county_fips;
END;

County_Fips_Of_Missing_Children := JOIN(HMK.mc_byStateDS,HMK.City_DS,
                                        LEFT.missingcity = std.str.toUpperCase(RIGHT.city) AND 
                                        LEFT.missingstate = RIGHT.state_id,
                                        County_Fips_Transform(LEFT,RIGHT));

OUTPUT(County_Fips_Of_Missing_Children,NAMED('County_Fips'));

CT_FIPS := TABLE(County_Fips_Of_Missing_Children,{County_Fips_Of_Missing_Children,number_of_missing_children := COUNT(GROUP)},county_fips);
Children_Per_Fip := OUTPUT(SORT(CT_FIPS,-number_of_missing_children),NAMED('MissByFIPS'));

CT_FIPS_Unemployment_Record := RECORD
  STRING county_fip;
  INTEGER number_of_missing_children;
  DECIMAL unemployment_rates;
 END;
 
 CT_FIPS_Unemployment_Record CT_FIPS_Unemployment_Transform(CT_FIPS Le, HMK.unemp_byCountyDS Ri) := TRANSFORM
  SELF.county_fip := Le.county_fips;
  SELF.number_of_missing_children := (INTEGER)Le.number_of_missing_children;
  SELF.unemployment_rates := (DECIMAL)Ri.value;
 END;
 
 
 CT_FIPS_Unemployment := JOIN(CT_FIPS, HMK.unemp_byCountyDS(Attribute = 'Unemployment_rate_2022'),
                              LEFT.county_fips = (STRING)RIGHT.fips_code,
                              CT_FIPS_Unemployment_Transform(LEFT,RIGHT));
                              
OUTPUT(SORT(CT_FIPS_Unemployment,-number_of_missing_children),NAMED('CT_FIPS_Unemployment'));
OUTPUT(CORRELATION(SORT(CT_FIPS_Unemployment,-number_of_missing_children), number_of_missing_children, unemployment_rates), NAMED('unemployment_correlation'));

CT_FIPS_Education_Record := RECORD
  STRING county_fip;
  INTEGER number_of_missing_children;
  INTEGER no_education;
END;

CT_FIPS_Education_Record CT_FIPS_Education_Transform(CT_FIPS Le, HMK.EducationDS Ri) := TRANSFORM
  SELF.county_fip := Le.county_fips;
  SELF.number_of_missing_children := (INTEGER)Le.number_of_missing_children;
  SELF.no_education := (INTEGER)Ri.value;
END;

CT_FIPS_Education := JOIN(CT_FIPS, HMK.EducationDS(attribute = 'Less than a high school diploma, 2017-21'),
                          LEFT.county_fips = (STRING)RIGHT.fips_code,
                          CT_FIPS_Education_Transform(LEFT,RIGHT));

OUTPUT(SORT(CT_FIPS_Education,-number_of_missing_children),NAMED('CT_FIPS_Education'));
OUTPUT(CORRELATION(SORT(CT_FIPS_Education,-number_of_missing_children),number_of_missing_children,no_education),NAMED('education_correlation'));

CT_FIPS_Poverty_Record := RECORD
  STRING county_fip;
  INTEGER number_of_missing_children;
  DECIMAL poverty_nums;
 END;
 
 CT_FIPS_Poverty_Record CT_FIPS_Poverty_Transform(CT_FIPS Le, HMK.pov_estimatesDS Ri) := TRANSFORM
  SELF.county_fip := Le.county_fips;
  SELF.number_of_missing_children := (INTEGER)Le.number_of_missing_children;
  SELF.poverty_nums := (DECIMAL)Ri.value;
 END;
 
 
 CT_FIPS_Poverty := JOIN(CT_FIPS, HMK.pov_estimatesDS(Attribute = 'POVALL_2021'),
                              LEFT.county_fips = (STRING)RIGHT.fips_code,
                              CT_FIPS_Poverty_Transform(LEFT,RIGHT));
                              
OUTPUT(SORT(CT_FIPS_Poverty,-number_of_missing_children),NAMED('CT_FIPS_Poverty'));
OUTPUT(CORRELATION(SORT(CT_FIPS_Poverty,-number_of_missing_children), number_of_missing_children, poverty_nums), NAMED('poverty_correlation'));

CT_FIPS_Population_Record := RECORD
  STRING county_fip;
  INTEGER number_of_missing_children;
  INTEGER population;
 END;
 
 CT_FIPS_Population_Record CT_FIPS_Population_Transform(CT_FIPS Le, HMK.pop_estimatesDS Ri) := TRANSFORM
  SELF.county_fip := Le.county_fips;
  SELF.number_of_missing_children := (INTEGER)Le.number_of_missing_children;
  SELF.population := (INTEGER)Ri.value;
END;

CT_FIPS_Population := JOIN(CT_FIPS, HMK.pop_estimatesDS(attribute = 'POP_ESTIMATE_2022'),
  LEFT.county_fips = (STRING)RIGHT.fips_code,
  CT_FIPS_Population_Transform(LEFT,RIGHT));
  

OUTPUT(SORT(CT_FIPS_Population,-number_of_missing_children),NAMED('CT_FIPS_Population'));
OUTPUT(CORRELATION(SORT(CT_FIPS_Population,-number_of_missing_children),number_of_missing_children,population),NAMED('population_correlation'));

Unemployment_Normalization_Record := RECORD
  String county_fip;
  DECIMAL normalized_unemployment;
END;

Unemployment_Normalization_Record Unemployement_Normaliztion_Transform(HMK.City_DS Le, HMK.unemp_byCountyDS Ri) := TRANSFORM
  SELF.county_fip := Le.county_fips;
  SELF.normalized_unemployment := ((Ri.value - 0.6)/(13-0.6))*100;
END;

Unemployment_Normalization := JOIN(HMK.City_DS, HMK.unemp_byCountyDS(Attribute = 'Unemployment_rate_2022'),
  LEFT.county_fips = (STRING)RIGHT.fips_code,
  Unemployement_Normaliztion_Transform(LEFT,RIGHT));
  
OUTPUT(SORT(Unemployment_Normalization, -normalized_unemployment),NAMED('Unemployment_Normalization'));
