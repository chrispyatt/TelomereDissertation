library(dplyr)
library(ggplot2)

read_excel_allsheets <- function(filename, tibble = FALSE) {
  # I prefer straight data.frames
  # but if you like tidyverse tibbles (the default with read_excel)
  # then just pass tibble = TRUE
  sheets <- readxl::excel_sheets(filename)
  x <- lapply(sheets, function(X) readxl::read_excel(filename, sheet = X))
  if(!tibble) x <- lapply(x, as.data.frame)
  names(x) <- sheets
  x
}

my_sheets <- read_excel_allsheets("SummarySansOutliers.xlsx")
plot_list = list()

for (i in c(1:length(my_sheets))) {
data <- my_sheets[i]
runName <- names(data)
df = get(runName, data)

gd <- df %>% group_by(Read_length, Sample) %>% summarise(MeanLengthEstimate = mean(Length), Min = min(Length), Max = max(Length), Sex = unique(Sex), YearOfBirth = unique(Year))
#newdata <- rbind(newdata, gd)

fitted_models = gd %>% group_by(Read_length) %>% do(model = lm(YearOfBirth ~ MeanLengthEstimate, data = .))
print(fitted_models$model)

p = ggplot(gd, aes(x = YearOfBirth, y = MeanLengthEstimate, shape = Sex, colour = Read_length)) +
  ggtitle(runName) + geom_point(size = 3) +
  geom_linerange(aes(ymin = Min, ymax= Max)) +
  #geom_text(label=r_sq, x = 2, y = 30) +
  scale_shape_manual(values = c(1, 4))
plot_list[[i]] = p
}

pdf("plots.pdf")
for (i in c(1:length(my_sheets))) {
  print(plot_list[[i]]) 
}
dev.off()
