include("ExactRefine.jl")

using Main.ExactRefiner
using CSV
using DataFrames

UBFactor = parse(Int, ARGS[1]);
solns = 10;

files = ["../Benchmarks/ASIC_Benchmarks_UnitWts/ISPD98_ibm01.weighted.hgr",
         "../Benchmarks/ASIC_Benchmarks_UnitWts/ISPD98_ibm02.weighted.hgr",
         "../Benchmarks/ASIC_Benchmarks_UnitWts/ISPD98_ibm03.weighted.hgr",
         "../Benchmarks/ASIC_Benchmarks_UnitWts/ISPD98_ibm04.weighted.hgr",
         "../Benchmarks/ASIC_Benchmarks_UnitWts/ISPD98_ibm05.weighted.hgr",
         "../Benchmarks/ASIC_Benchmarks_UnitWts/ISPD98_ibm06.weighted.hgr",
         "../Benchmarks/ASIC_Benchmarks_UnitWts/ISPD98_ibm07.weighted.hgr",
         "../Benchmarks/ASIC_Benchmarks_UnitWts/ISPD98_ibm08.weighted.hgr",
         "../Benchmarks/ASIC_Benchmarks_UnitWts/ISPD98_ibm09.weighted.hgr",
         "../Benchmarks/ASIC_Benchmarks_UnitWts/ISPD98_ibm10.weighted.hgr",
         "../Benchmarks/ASIC_Benchmarks_UnitWts/ISPD98_ibm11.weighted.hgr",
         "../Benchmarks/ASIC_Benchmarks_UnitWts/ISPD98_ibm12.weighted.hgr",
         "../Benchmarks/ASIC_Benchmarks_UnitWts/ISPD98_ibm13.weighted.hgr",
         "../Benchmarks/ASIC_Benchmarks_UnitWts/ISPD98_ibm14.weighted.hgr",
         "../Benchmarks/ASIC_Benchmarks_UnitWts/ISPD98_ibm15.weighted.hgr",
         "../Benchmarks/ASIC_Benchmarks_UnitWts/ISPD98_ibm16.weighted.hgr",
         "../Benchmarks/ASIC_Benchmarks_UnitWts/ISPD98_ibm17.weighted.hgr",
         "../Benchmarks/ASIC_Benchmarks_UnitWts/ISPD98_ibm18.weighted.hgr"];

benchmark = ["ibm01", "ibm02", "ibm03", "ibm04", "ibm05", "ibm06", "ibm07", "ibm08", "ibm09",
             "ibm10", "ibm11", "ibm12", "ibm13", "ibm14", "ibm15", "ibm16", "ibm17", "ibm18"];

hM = zeros(Int, length(benchmark));
xR = similar(hM);
N = similar(hM);
E = similar(hM);

for i in 1:length(files)
    println("Running ", files[i])
    (hmetis_c, xRefine_c, n, m) = Main.ExactRefiner.xRefine(files[i], "../Tune_Prac/", solns, UBFactor);
    hM[i] = hmetis_c;
    xR[i] = xRefine_c;
    N[i] = n;
    E[i] = m;
end

d = DataFrame(Benchmark = benchmark, hMetis = hM, xRefine = xR, Vtxs = N, Hdges = E);
CSV.write("PtnResults_" * ARGS[1] * ".csv", d);
#CSV.write("PtnResults_NoFixed" * ARGS[1] * ".csv", d);