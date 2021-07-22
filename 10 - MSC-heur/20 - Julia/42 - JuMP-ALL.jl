using JuMP
using GLPK   # MILP
using Cbc    # MILP
using CPLEX  # MILP
using Gurobi # MILP
using SCIP         # MILP + MINLP
using AmplNLWriter # MILP + MINLP
using NEOSServer   # MILP + MINLP
using Juniper, Ipopt # MINLP
using Alpine, Ipopt  # MINLP
using Pavito, Ipopt  # MINLP

function main()
    m = JuMP.Model()
    @variable(m, x >= 0)
    @variable(m, y >= 0, Bin)
    @objective(m, Min, y)
    @constraint(m, y >= x - 1)

    # ** MILP **

    mipSOLVER = () -> GLPK.Optimizer()
    # "tm_lim" => 60 * 1000
    # "msg_lev" => GLPK.GLP_MSG_ALL
    mipSOLVER = () -> Cbc.Optimizer()
    # "seconds" => 60
    # "logLevel" => 1
    mipSOLVER = () -> CPLEX.Optimizer()
    mipSOLVER = () -> Gurobi.Optimizer()
    # "TimeLimit" => 60

    # ** MILP + MINLP **

    minlpSOLVER = () -> SCIP.Optimizer()
    amplexe = "/Users/rlinfati/Applications/ampl_macos64/baron"  #       MINLP
    amplexe = "/Users/rlinfati/Applications/ampl_macos64/xpress" # MILP
    amplexe = "/Users/rlinfati/Applications/ampl_macos64/knitro" # MILP, MINLP
    minlpSOLVER = () -> AmplNLWriter.Optimizer(amplexe)
    minlpSOLVER = () -> NEOSServer.Optimizer(email = "user@domain.tld", solver = "MOSEK")
    # CPLEX, FICO-Xpress, Gurobi, Ipopt, MOSEK and SNOPT.

    # ** MINLP **
    IpoptSolver = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "print_level" => 0)
    CbcSolver = JuMP.optimizer_with_attributes(Cbc.Optimizer, "logLevel" => 0)
    JuniperSolver = JuMP.optimizer_with_attributes(
        Juniper.Optimizer,
        "nl_solver" => IpoptSolver,
        "mip_solver" => CbcSolver,
        "log_levels" => [],
    )

    minlpSOLVER = JuniperSolver
    minlpSOLVER = JuMP.optimizer_with_attributes(
        Alpine.Optimizer,
        "nlp_solver" => IpoptSolver,
        "mip_solver" => CbcSolver,
        "minlp_solver" => JuniperSolver,
    )
    minlpSOLVER =
        JuMP.optimizer_with_attributes(Pavito.Optimizer, "cont_solver" => IpoptSolver, "mip_solver" => CbcSolver)

    JuMP.set_optimizer(m, mipSOLVER)
    JuMP.optimize!(m)

    return
end

main()
