using JuMP, Gurobi

inputfile = "sample.csv"
csvdata = readcsv(inputfile, header = true)
data = csvdata[1]
header = csvdata[2]

#Extract data to variables
activityName = data[:,1]
METS = data[:,2]
time = data[:,3]
intensity = data[:,4]
targetTime = data[1,10]
targetMET = data[1,11]
# targetIntensity = data[1,13]
BMI = data[1,12]
N = length(activityName)

#Compare targetMET & BMI to ensure valid target
if targetMET >= BMI
  targetMET = BMI #set as BMI limit
end

#specify intensity
#specify equipment
#specify cardio
#specify upper,lower,core

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

println("Optimum METS burned = $(getobjectivevalue(problem)).")
if getobjectivevalue(problem) <= targetMET
  println("METs burned is ", targetMET - getobjectivevalue(problem), " below your target due to BMI constraints.")
else
  println("METs target is achievable!")
end
