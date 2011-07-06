setwd("~/Dropbox/code/sarah-palin-lda")

library(ggplot2)
library(plyr)

d = read.table("emails-with-metadata.txt", sep = "\t", header = F, comment.char = "", quote = "")
colnames(d) = c("id", "year", "month", "day", "hour", "wday", "w1", "w2", "w3", "w4", "w5", "w6", "w7", "w8", "w9", "w10", "w11", "w12", "w13", "w14", "w15", "w16", "w17", "w18", "w19", "w20", "w21", "w22", "w23", "w24", "w25", "w26", "w27", "w28", "w29", "w30")
d = subset(d, 2006 <= year & year <= 2011)
d = transform(d, time = year * 12 + (month - 1))

x = ddply(d, .(time, year, month), summarise, w1 = sum(w1), w2 = sum(w2), w3 = sum(w3), w4 = sum(w4), w5 = sum(w5), w6 = sum(w6), w7 = sum(w7), w8 = sum(w8), w9 = sum(w9), w10 = sum(w10), w11 = sum(w11), w12 = sum(w12), w13 = sum(w13), w14 = sum(w14), w15 = sum(w15), w16 = sum(w16), w17 = sum(w17), w18 = sum(w18), w19 = sum(w19), w20 = sum(w20), w21 = sum(w21), w22 = sum(w22), w23 = sum(w23), w24 = sum(w24), w25 = sum(w25), w26 = sum(w26), w27 = sum(w27), w28 = sum(w28), w29 = sum(w29), w30 = sum(w30), total = sum(w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17, w18, w19, w20, w21, w22, w23, w24, w25, w26, w27, w28, w29, w30))
x = subset(x, time < 24110)
x = subset(x, time > 24080)
x_scale = scale_x_continuous(breaks = c(24084, 24090, 24096, 24099, 24102, 24108), labels = c("Jan '07", "Jul '07", "Jan '08", "Apr '08", "Jul '08", "Jan '09"))
qplot(time, w20 / total, data = x, xlab = "date", ylab = "% of emails") + x_scale + geom_line() + scale_y_continuous(formatter = "percent") + opts(title = "Topic: Trig/Family/Inspiration")