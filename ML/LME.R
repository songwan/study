### Overview
# Components for mixed-effect models
# Applying and interpreting linear mixed-effect models
# Generalized linear mixed-effect models
# Repeated measure models

### Why do we use a hierarchical model?
# Data nested within itself
# Pool information across small sample sizes
# Repeated observations across groups or individuals

### Other names for hierarchical models
# Hierarchical models: Nested models, Multi-level models
# Regression framework
# - "pool" information
# - "random-effect" vs "fixed-effect"
# - "mixed-effect" (linear mixed-effect model; LMM)
# - linear mixed-effect regression (lmer)
# Releated sampling
# - "repeated-measures", "paired-tests"

### Datasets
# Student-level: childid, mathgain(math test score), mathdind(math kindergarten score), sex
# Classroom-level: classid, mathprep(teacher's math training), mathknow, yearstea
# School-level: schoolid, housepov, ses

# Plot the data
ggplot(data = student_data, aes(x = mathknow, y = mathgain)) +
    geom_point() +
    geom_smooth(method = 'lm')

# Fit a linear model
summary(lm(mathgain ~ mathknow , data =  student_data))

# Summarize the student data at the classroom level
class_data <-
    student_data %>%
    group_by(classid, schoolid) %>%
    summarize(mathgain_class = mean(mathgain),
              mathknow_class = mean(mathknow),
              n_class = n(), .groups = "keep")

# Model the math gain with the student-level data
lm(mathgain ~ mathknow, data = student_data)

# Model the math gain with the classroom-level data
lm(mathgain_class ~ mathknow_class, data = class_data)

# Summarize the data at the school level
school_data <-
    student_data %>%
    group_by(schoolid) %>%
    summarize(mathgain_school = mean(mathgain),
              mathknow_school = mean(mathknow),
              n_school = n(), .groups = 'keep')

# Model the data at the school-level
lm(mathgain_school ~ mathknow_school, data = school_data)

# Summarize school by class (s_by_c)
s_by_c_data <-
    class_data %>%
    group_by(schoolid) %>%
    summarize(mathgain_s_by_c = mean(mathgain_class),
              mathknow_s_by_c = mean(mathknow_class),
              n_s_by_c = n(), .groups = 'keep')

# Model the data at the school-level after summarizing
# students at the class level
lm(mathgain_s_by_c ~ mathknow_s_by_c, data = s_by_c_data)

# Use a linear model to estimate the global intercept
lm(mathgain~1, data = school_3_data)

# Use summarize to calculate the mean
school_3_data %>%
    summarize(mean(mathgain))

# Use a linear model to estimate mathgain in each classroom
lm(mathgain~classid, data=school_3_data)

# Change classid to be a factor
school_3_data <-
    school_3_data %>%
    mutate(classid = factor(classid))

# Use a linear model to estimate mathgain in each classroom
lm(mathgain~classid, data=school_3_data)

# Change classid to be a factor
school_3_data <-
    school_3_data %>%
    mutate(classid = factor(classid))

# Calculate the mean of mathgain for each class
school_3_data %>%
    group_by(classid) %>%
    summarize(n(), mathgain_class = mean(mathgain))

# Estimate an intercept for each class
lm(mathgain ~ classid - 1, data = school_3_data)

# Use a linear model to estimate how math kindergarten
# scores predict math gains later
lm(mathgain ~ mathkind, data = school_3_data)

# Build a multiple regression
lm(mathgain ~ classid + mathkind -1, data=school_3_data)

# Build a multiple regression with interaction
lm(mathgain ~ classid*mathkind -1, data=school_3_data)

# Build a liner model including class as fixed-effect model
lm_out <- lm(mathgain ~ classid + mathkind, data = student_data)

# Build a mixed-effect model including class id as a random-effect
lmer_out <- lmer(mathgain ~ mathkind + (1 | classid), data = student_data)

# Extract out the slope estimate for mathkind
tidy(lm_out) %>%
    filter(term == "mathkind")
    
tidy(lmer_out) %>%
    filter(term == "mathkind")

# Re-run the models to load their outputs
lm_out <- lm(mathgain ~ classid + mathkind, data = student_data)
lmer_out <- lmer(mathgain ~ mathkind + (1 | classid), data = student_data)

# Add the predictions to the original data
student_data_subset <-
    student_data %>%
    mutate(lm_predict = predict(lm_out),
           lmer_predict = predict(lmer_out)) %>%
    filter(schoolid == "1")

# Plot the predicted values
ggplot(student_data_subset,
       aes(x = mathkind, y = mathgain, color = classid)) +
    geom_point() +
    geom_line(aes(x = mathkind, y = lm_predict)) +
    geom_line(aes(x = mathkind, y = lmer_predict), linetype = 'dashed') +
    xlab("Kindergarten math score") +
    ylab("Math gain later in school") +
    theme_bw() +
    scale_color_manual("Class ID", values = c("red", "blue"))


# Rescale mathkind to make the model more stable
student_data <-
	student_data %>%
    mutate(mathkind_scaled = scale(mathkind))

# Build lmer models
lmer_intercept <- lmer(mathgain ~ mathkind_scaled + (1 | classid), data = student_data)
lmer_slope <- lmer(mathgain ~ (mathkind_scaled | classid), data = student_data)

# Rescale mathkind to make the model more stable
student_data <-
	student_data %>%
    mutate(mathkind_scaled = scale(mathkind))

# Re-run the models to load their outputs
lmer_intercept <- lmer(mathgain ~ mathkind_scaled + (1 | classid),
                       data = student_data)
lmer_slope     <- lmer(mathgain ~ (mathkind_scaled | classid),
                       data = student_data)

# Add the predictions to the original data
student_data_subset <-
    student_data %>%
    mutate(lmer_intercept = predict(lmer_intercept),
           lmer_slope = predict(lmer_slope)) %>%
    filter(schoolid == "1")

# Plot the predicted values
ggplot(student_data_subset,
       aes(x = mathkind_scaled, y = mathgain, color = classid)) +
    geom_point() +
    geom_line(aes(x = mathkind_scaled, y = lmer_intercept)) +
    geom_line(aes(x = mathkind_scaled, y = lmer_slope), linetype = 'dashed') +
    theme_bw() +
    scale_color_manual("Class ID", values = c("red", "blue"))

# Build the model
lmer_classroom = lmer(mathgain ~ mathknow + mathprep + sex + mathkind + ses + (1|classid),
                      data = student_data)

# Print the model's output
print(lmer_classroom)

# Extract coefficents
lmer_coef <-
    tidy(lmer_classroom, conf.int = TRUE)

# Plot results
lmer_coef %>%
    filter(effect == "fixed" & term != "(Intercept)") %>%
    ggplot(., aes(x = term, y = estimate,
                  ymin = conf.low, ymax = conf.high)) +
    geom_hline(yintercept = 0, color = 'red') + 
    geom_point() +
    geom_linerange() +
    coord_flip() +
    theme_bw() +
    ylab("Coefficient estimate and 95% CI") +
    xlab("Regression coefficient")

# Build a lmer with State as a random effect.
birth_rate_state_model <- lmer(BirthRate ~ (1 | State),
                            data = county_births_data)
# Plot the predicted values from the model on top of the plot shown during the video.
county_births_data$birthPredictState <-
	predict(birth_rate_state_model, county_births_data)
ggplot() + 
    theme_minimal() +
    geom_point(data = county_births_data,
               aes(x = TotalPopulation, y = BirthRate)) + 
    geom_point(data = county_births_data,
               aes(x = TotalPopulation, y = birthPredictState),
               color = 'blue', alpha = 0.5) 

# Include the AverageAgeofMother as a fixed effect within the lmer and state as a random effect
age_mother_model <- lmer(BirthRate ~ AverageAgeofMother + (1 | State),
                       county_births_data)
summary(age_mother_model)

# Include the AverageAgeofMother as fixed-effect and State as a random-effect
model_a <- lmer(BirthRate ~ AverageAgeofMother + (1|State), county_births_data)
tidy(model_a)

# Include the AverageAgeofMother as fixed-effect and LogTotalPop and State as random-effects
model_b <- lmer(BirthRate ~ AverageAgeofMother + (LogTotalPop|State), county_births_data)
tidy(model_b)
# -> perhaps the log(total_pop) changes the birth rate of a country and varies by state

# Include AverageAgeofMother as fixed-effect and LogTotalPop and State as uncorrelated random-effects
model_c <- lmer(BirthRate ~ AverageAgeofMother + (LogTotalPop||State),
                county_births_data)
# Compare outputs of both models 
summary(model_b)
summary(model_c)

# Construct a lmer() 
out <- lmer(BirthRate ~ AverageAgeofMother + (AverageAgeofMother|State),
            data = county_births_data)


# Look at the summary
summary(out)

# Fit a glm using data in a long format
fit_long <- glm(mortality ~ dose, data = df_long, 
                family = "binomial")
summary(fit_long)

# Fit a glm using data in a short format with two columns
fit_short <- glm(cbind(mortality, survival) ~ dose, 
                data = df_short, family = "binomial")
summary(fit_short)

# Fit a glm using data in a short format with weights
fit_short_p <- glm(mortalityP  ~ dose , data = df_short, 
                   weights = nReps , family = "binomial")
summary(fit_short_p)

# Fit the linear model
summary(lm(y~x))

# Fit the generalized linear model
summary(glm(y~x, family = "poisson"))

# Plot the data using jittered points and the default stat_smooth
ggplot(data = df_long, aes(x = dose, y = mortality)) + 
	geom_jitter(height = 0.05, width = 0.1) +
	stat_smooth(fill = 'pink', color = 'red') 

# Fit glmOut and look at its coefficient estimates 
glm_out <- glm(mortality ~ dose + replicate - 1, 
              family = "binomial", data = df)
coef(glm_out)

# Load lmerTest
library(lmerTest)

# Fit glmerOut and look at its coefficient estimates 
glmer_out <- glmer(mortality ~ dose + (1|replicate), 
                   family = "binomial", data = df)
coef(glmer_out)

# Load lmerTest
library(lmerTest)

# Fit the model and look at its summary 
model_out <- glmer(cbind(Purchases, Pass) ~ friend + ranking + (1|city), family='binomial', data=all_data)
summary(model_out) 

# Run the code to see how to calculate odds ratios
summary(model_out) 
exp(fixef(model_out))
exp(confint(model_out))

# Create the tidied output
tidy(model_out, conf.int = T, exponentiate = T)

# Set the seed to be 345659
set.seed(345659)

# Model 10 individuals 
n_ind <- 10

# simulate before with mean of 0 and sd of 0.5
before <- rnorm(n_ind, mean = 0, sd = 0.5)
# simulate after with mean effect of 4.5 and standard devation of 5
after  <- before + rnorm(n_ind, mean = 4.5, sd = 5)

# Run a standard, non-paired t-test
t.test(x = before, y =after, paired = F)

# Run a standard, paired t-test
t.test(x = before, y =after, paired = T)

library(lmerTest)

# Run the code from the previous step
dat <- data.frame(y = c(before, after), 
                  trial = rep(c("before", "after"), each = n_ind),
                  ind = rep(letters[1:n_ind], times = 2))

# Run a standard, paired t-test
t.test(x=before, y=after, data=dat, paired=T)

# Run a lmer and save it as lmer_out
lmer_out <- lmer(y ~ trial + (1|ind), data=dat)

# Look at the summary() of lmer_out
summary(lmer_out)

# Add an x and y label to the plot and change the theme to be "minimal"
ggplot(sleep, aes(x = group, y = extra, group = ID)) +
  geom_line() +
  xlab(label = "Drug") +
  ylab(label = "Extra sleep") + 
  theme_minimal()

  # Add a Poisson trend line for each county
ggplot(data = hate, aes(x = Year, y = TotalIncidents, group = County)) +
    geom_line() +
	geom_smooth(method = "glm", method.args = c("poisson"), se = FALSE)

# load the edit you previously made
hate$Year2 <- hate$Year - min(hate$Year)

# build a glmer with County as a random-effect intercept and Year2 as both a fixed- and random-effect slope
glmer_out <- glmer(TotalIncidents ~ Year2 + (Year2|County), data = hate, family = "poisson")

# Extract out the fixed-effect slope for Year2
Year2_slope <- fixef(glmer_out)['Year2']

# Extract out the random-effect slopes for county
county_slope <- ranef(glmer_out)$County

# Create a new column for the slope
county_slope$slope <- county_slope$Year2 + Year2_slope

# Use the row names to create a county name column
county_slope$county <- rownames(county_slope)

# Create an ordered county-level factor based upon slope values
county_slope$county_plot <- factor(county_slope$county, 
                                   levels = county_slope$county[order(county_slope$slope)])

# Now plot the results
ggplot(data = county_slope, aes(x = county_plot, y = slope)) + 
	geom_point() +
    coord_flip() + 
	theme_bw() + 
	ylab("Change in hate crimes per year")  +
    xlab("County")