using JuMP, Gurobi

inputfile = "sample.csv"
csvdata = readcsv(inputfile, header = true)
data = csvdata[1]
header = csvdata[2]

#Extract data to variables
activityName = data[:,1]
METS = data[:,2]
time = data[:,3]
targetTime = data[1,4]
targetMET = data[1,5]
BMI = data[:,6]
N = length(activityName)

problem = Model(solver = GurobiSolver())

#Declaring variables
@variable(problem, x[1:N], Bin)

#Setting the objective
@objective(problem, Max, sum{METS[i] * x[i], i = 1:N})

#Setting the constraints
@constraint(problem, sum{METS[i] * x[i], i = 1:N} <= targetMET) #target MET
@constraint(problem, sum{time[i] * x[i], i = 1:N} <= targetTime) #target time limit

print(problem)
solve(problem)

#Display Optimal Binary Solutions
# println("Optimal Solutions:")
# for i=1:N
#   println(activityName[i] ,"= ", getvalue(x[i]))
# end

#Print exercises that are selected
println("Exercises you should do:")
for i = 1:N
    if getvalue(x[i]) == 1
        println("Please do ", activityName[i], " for ", time[i], " minutes.")
   end
end
