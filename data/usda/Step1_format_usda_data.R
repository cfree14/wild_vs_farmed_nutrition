
# Read data
################################################################################

# Clear workspace
rm(list = ls())

# Packages
library(tidyverse)

# Directories
indir <- "data/usda/raw"
outdir <- "data/usda/processed"

# Read keys
list.files(indir)
count_key <- read.csv(file.path(indir, "all_downloaded_table_record_counts.csv")) # boring
attr_type_key <- read.csv(file.path(indir, "food_attribute_type.csv")) # boring
attr_key <- read.csv(file.path(indir, "food_attribute.csv")) # boring
cal_conv_key <- read.csv(file.path(indir, "food_calorie_conversion_factor.csv")) # boring
food_catg_key_orig <- read.csv(file.path(indir, "food_category.csv")) # boring
nutr_conv_key <- read.csv(file.path(indir, "food_nutrient_conversion_factor.csv")) # boring
deriv_key_orig <- read.csv(file.path(indir, "food_nutrient_derivation.csv")) # boring
nutr_source_key <- read.csv(file.path(indir, "food_nutrient_source.csv")) # boring
protein_conv_key <- read.csv(file.path(indir, "food_protein_conversion_factor.csv")) # boring
update_key <- read.csv(file.path(indir, "food_update_log_entry.csv")) # boring
food_key_orig <- read.csv(file.path(indir, "food.csv")) # boring
unit_key_orig <- read.csv(file.path(indir, "measure_unit.csv")) # boring
nutr_key_orig <- read.csv(file.path(indir, "nutrient.csv")) # boring
retn_factor_key <- read.csv(file.path(indir, "retention_factor.csv")) # boring
legacy_key <- read.csv(file.path(indir, "sr_legacy_food.csv")) # boring

# Read data
nutr_data_orig <- read.csv(file.path(indir, "food_nutrient.csv"), na.strings = "") # boring
portion_data_orig <- read.csv(file.path(indir, "food_portion.csv")) # boring


# Format keys
################################################################################

# Format nutrient key
nutr_key <- nutr_key_orig %>% 
  rename(nutrient_id=id, 
         nutrient=name,
         nutrient_units=unit_name,
         nutrient_code=nutrient_nbr)

# Inspect
table(nutr_key$nutrient_units)

# Format derivation key
deriv_key <- deriv_key_orig %>% 
  rename(derivation_id=id, 
         derivation_code=code,
         derivation=description)

# Format food category key
food_catg_key <- food_catg_key_orig %>% 
  rename(food_catg_id=id, 
         food_catg=description,
         food_catg_code=code)

# Format food key
food_key <- food_key_orig %>%
  # Rename
  rename(food_id=fdc_id, 
         food=description,
         food_catg_id=food_category_id) %>% 
  # Add category
  left_join(food_catg_key %>% select(food_catg_id, food_catg), by="food_catg_id")

# Format unit key
unit_key <- unit_key_orig %>% 
  rename(unit_id=id,
         unit=name)


# Build nutrient data
################################################################################

# Format nutrient data
nutr_data <- nutr_data_orig %>% 
  # Rename
  rename(food_id=fdc_id,
         amount_min=min,
         amount_max=max,
         amount_med=median,
         n_obs=data_points,
         year=min_year_acquired) %>% 
  # Add nutrient
  left_join(nutr_key %>% select(nutrient_id, nutrient, nutrient_units), by="nutrient_id") %>% 
  # Add food info
  left_join(food_key %>% select(food_id, food, food_catg), by="food_id") %>% 
  # Add derviation
  left_join(deriv_key %>% select(derivation_id, derivation), by="derivation_id") %>% 
  # Arrange
  select(id, 
        food_catg, food,  food_id, 
        nutrient, nutrient_id, nutrient_units,
        amount, amount_min, amount_max, amount_med, 
        year, n_obs,
        derivation_id, derivation, footnote,
        everything())

# Inspect
table(nutr_data$food_catg)

# Export
saveRDS(nutr_data, file=file.path(outdir, "usda_nutrient_data.Rds"))

# Exmaple plot
# ggplot(nutr_data %>% filter(food_catg=="Beef Products"), aes(x=amount, y=food)) +
#   facet_wrap(~nutrient, ncol=6) +
#   geom_boxplot() +
#   theme_bw()


# Build portion data
################################################################################

# Format portion data
portion_data <- portion_data_orig %>% 
  # Rename
  rename(food_id=fdc_id,
         unit_id=measure_unit_id) %>% 
  # Add food info
  left_join(food_key %>% select(food_id, food, food_catg), by="food_id") %>% 
  # Add unit info
  left_join(unit_key, by="unit_id") %>% 
  # Arrange
  select(id, 
         food_catg, food,  food_id, 
         everything())
  





