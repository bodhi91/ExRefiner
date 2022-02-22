import re
import subprocess
import os
import ray
import sys
from ray import tune
from ray.tune.suggest import ConcurrencyLimiter
from ray.tune.schedulers import AsyncHyperBandScheduler
from ray.tune.suggest.hyperopt import HyperOptSearch

def evaluation_fn(x):
    m = re.search(r'(?<=Hyperedge Cut:)\s+\d+', x)
    return int(m.group(0).replace(" ", ""))

def easy_objective(config):
    CType, RType, Vcycle, Reconst = config["CType"], config["RType"], config["Vcycle"], config["Reconst"]
    fname = config["fname"]
    UBFactor = config["UBFactor"]
    pwd = "/home/bodhi91/DEV/sandbox/Partitioner/Tune_Prac/"
    hmetis_f = pwd+"/hmetis"
    fname_r = re.search(r'(?<=ISPD98_)\S+', fname)
    b_name = fname_r.group(0)
    b_name_f = re.search(r'\S+(?=.weighted.hgr)', b_name).group(0)
    b_name_loc = pwd+b_name_f
    trial_id = tune.get_trial_id()
    trial_file_name = b_name_f + trial_id
    mkdir_op = subprocess.run(["mkdir", b_name_loc+"/"+trial_file_name], stdout=subprocess.PIPE, text=True).stdout
    dst_f = b_name_loc+"/"+trial_file_name+"/"
    cp_op = subprocess.run(["cp", fname, dst_f])
    new_bnchmrk_name = dst_f+"ISPD98_"+b_name
    
    for step in range(config["steps"]):
        x = subprocess.Popen(["/home/bodhi91/DEV/sandbox/Partitioner/Tune_Prac/hmetis", new_bnchmrk_name, "2", str(UBFactor), "10", str(CType), str(RType), str(Vcycle), str(Reconst), "0"], stdout=subprocess.PIPE)    
        subprocess_return = x.stdout.read()
        intermediate_score = evaluation_fn(str(subprocess_return))
        tune.report(iterations=step, mean_loss=intermediate_score)

    rm_op = subprocess.run(["rm", new_bnchmrk_name], stdout=subprocess.PIPE, text=True).stdout

if __name__ == "__main__":
   
    import argparse

    parser = argparse.ArgumentParser()
    #parser.add_argument()
    parser.add_argument(
        "--smoke-test", action="store_true", help="Finish quickly for testing")
    parser.add_argument(
        "--server-address",
        type=str,
        default=None,
        required=False,
        help="The address of server to connect to if using "
        "Ray Client.")
    args, _ = parser.parse_known_args()

    if args.server_address:
        ray.init(f"ray://{args.server_address}")
    else:
        ray.init(configure_logging=False)

    ubfac = sys.argv[2]

    current_best_params = [
        {
            "UBFactor": ubfac,
            "CType": 1,
            "RType": 1,
            "Vcycle": 1,  # Activation will be relu
            "Reconst": 0
     }]
    
    fname = "/home/bodhi91/DEV/sandbox/Partitioner/Benchmarks/Tune_Benchmarks/"+sys.argv[1]
    #fname = "/home/bodhi91/DEV/sandbox/Partitioner/Benchmarks/Tune_Benchmarks/ISPD98_ibm02.weighted.hgr"
    fname_r = re.search(r'(?<=ISPD98_)\S+', fname)
    b_name = fname_r.group(0)
    b_name_f = re.search(r'\S+(?=.weighted.hgr)', b_name).group(0)
    b_name_loc = "/home/bodhi91/DEV/sandbox/Partitioner/Tune_Prac/"+b_name_f
    isdir = os.path.isdir(b_name) 
    if isdir == True:
        rm_op = subprocess.run(["rm", "-r", b_name_loc])
        mkdir_op = subprocess.run(["mkdir", b_name_loc], stdout=subprocess.PIPE, text=True).stdout
    else:
        mkdir_op = subprocess.run(["mkdir", b_name_loc], stdout=subprocess.PIPE, text=True).stdout

    algo = HyperOptSearch(points_to_evaluate=current_best_params)
    algo = ConcurrencyLimiter(algo, max_concurrent=12)

    scheduler = AsyncHyperBandScheduler(max_t=1000)
    analysis = tune.run(
        easy_objective,
        local_dir="/home/bodhi91/DEV/sandbox/Partitioner/",
        search_alg=algo,
        scheduler=scheduler,
        metric="mean_loss",
        mode="min",
        num_samples=40,
        verbose=3,
        config={
            "UBFactor": ubfac,
            "fname": fname,
            "steps": 1,
            "CType": tune.choice([1,2,3,4,5]),
            "RType": tune.choice([1,2,3]),
            "Vcycle": tune.choice([0,1,2,3]),
            "Reconst": tune.choice([0,1])
        })
    
    print("Best hyperparameters found were: ", analysis.best_config)
    print("Best cut-size: ", analysis.best_result)

