library(torch)

print(torch::cuda_is_available())

write.csv("This is a test.", "test.csv")
