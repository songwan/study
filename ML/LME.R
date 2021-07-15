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