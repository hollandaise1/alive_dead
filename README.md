# Customer Segmentation
[![pipeline status](https://git.tmaws.io/Fiona.Li/customer_segmentation/badges/master/pipeline.svg)](https://git.tmaws.io/Fiona.Li/customer_segmentation/commits/master)
[![coverage report](https://git.tmaws.io/Fiona.Li/customer_segmentation/badges/master/coverage.svg)](https://git.tmaws.io/Fiona.Li/customer_segmentation/commits/master)


This repository contains a Python script and Pytest files with
required Docker implementation files. The end results, such as
predicted probabilities at customer level, are reflected at Salesforce
Marketing Cloud (SFMC) tables.

## Motivation
This repository is intended to for the Customer Segmentation project
prioritized for Q2 2019. There are two major objectives associated
with this project at this point of time. The overall goal is to
decrease marketing costs and make marketing more efficient.

* **Objective #1**: Segment users according to whether we believe they are "alive" or "dead" (from a purchase perspective).
    *  Strategy: Reduce spend on users who are not going to purchase.

* **Objective #2**: Predict when customers will make their next purchase.
    *  Strategy: Reduce spend on users who will purchase event without marketing.


## Getting Started
### The Directory Structure
```
├── README.md                                       <- The top-level README for developers using this project.
├── Dockerfile                                      <- Docker container file.
├── Pipfile                                         <- Pipfile with all required packages.
├── Pipfile.lock                                    <- Part of the pipfile with encrypted and hashed packages.
├── docker-compose.yml                              <- YML file to compose the dockerfile.
├── pyproject.yml                                   <- YML file for pyproject.
├── pytest.ini                                      <- YML file to initialize the pytest.
│
├── src                                             <- Source code for use in this project.
│   ├── __init__.py                                 <- Initialization Python script.
│   ├── config.toml                                 <- TOML file for all configurations: cohorts, s3, SFMC.
│   ├── cust_status.py                              <- The main function sits here.
│   ├── get_data.py                                 <- Get data from Teradata.
│   ├── helpers.py                                  <- Athena table creation.
│   ├── optimization.py                             <- BG/BB optimization function.
│   ├── preprocessing.py                            <- From data pulled from Teradata to RFM matrix.
│   │
│   ├── queries                                     <- Teradata queries.
│   │   ├── create_tables.sql                       <- Teradata query that creates multiple temp tables. 
│   │   ├── purchase_data.sql                       <- Teradata query that pulls purchase data. 
│   │   └── cleanup.sql                             <- Teradata query that drops temp tables. 
│   │
│   └── archive                                     <- Archive folder for legacy scripts.
│       ├── install_r_packages.py                   <- Python script that installs R packages, i.e. BTYD.
│       ├── cust_status_yearly.R                    <- Deprecated R script that creates the predictions for yearly cohort.
│       └── cust_status_monthly.R                   <- Deprecated R script that creates the predictions for monthly cohort.
│
├── tests                                           <- All testing cases for this project.
│   ├── __init__.py                                 <- Initialization Python script.
│   ├── context.py                                  <- Context Python script to let scripts "knows" about the other scripts.
│   ├── test_get_data.py                            <- Test all functions in the scr/get_data.py
│   ├── test_helpers.py                             <- Test all functions in the scr/helpers.py
│   ├── test_ltv.py                                 <- Test all functions in the scr/cust_status.py
│   ├── test_optimization.py                        <- Test all functions in the scr/optimization.py
│   ├── test_preprocessing.py                       <- Test all functions in the scr/preprocessing.py
│   │
│   └── resources                                   <- Resources for testing data, sample results etc.
│       ├── cohort_data.csv                         <- Test data.
│       ├── config.toml                             <- TOML file for configurations.
│       ├── output_integration.csv                  <- Sample data for .
│       ├── palive.csv                              <- Intermediate data that has been transformed.
│       └── recency_frequency_matrix_example.csv    <- The original, immutable data dump.
│
├── references                                      <- Source code for use in this project.
│   ├── .gitkeep                                    <- Makes src a Python module
│   ├── HW6_2018_Spreadsheet_Solutions.xlsx         <- Makes src a Python module
│   └── HW_6_Solutions_Spring_2018.pdf              <- Makes src a Python module
│
├── etc                                             <- Source code for use in this project.
│   ├── Dockerfile                                  <- Makes src a Python module   
│   ├── bootstrap.sh                                <- Makes src a Python module
│   ├── datapipeline-templ.json                     <- Makes src a Python module
│   ├── recreate_pipeline_prod.sh                   <- Makes src a Python module
│   └── recreate_pipeline_staging.sh                <- Makes src a Python module
│
├── .gitignore                                      <- Data dictionaries, manuals, and all other explanatory materials.
└── .gitlab-ci.yml                                  <- tox file with settings for running tox; see tox.testrun.org
```

### Building the Docker image
To build the Docker image after cloning the repo, do:

```
$ docker build --build-arg AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} --build-arg AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} -t alive_or_dead:latest .
```

To run it in the default mode (running the script), do:

```
$ docker run --name alive-or-dead alive_or_dead:latest
```


### Running the test cases

The mathematical functions used in this project were fully tested and
passed unit, integration and regression tests. We leveraged the
hyperparameters used in [Fad:18] to create the regression test cases
for the MLE related functions. Thus, the hyperparameters (α, β, γ and
δ) generated from running the test script should be consistent with
the [FH:11] Solver solution on tab "BG-BB Estimation".

The test cases can be run directly on your computer or in a Docker
container. Running directly on your computer will require installing
the required libraries but will generate an html-based code coverage
report. Running the test cases in a Docker container will show you a
code coverage summary, but not the detailed report.

Running on your computer:

```
$ pipenv shell
$ pipenv install
$ python -m pytest
```

To run in the Docker container, first build the Docker image as
described above. Then, instead of using the default run command, do:

```
$ docker run --name alive-or-dead --entrypoint "/bin/bash" alive_or_dead:latest -c "pipenv run python -m pytest"
```

### Checking code formatting
This project uses [black](https://github.com/python/black) to enforce
consistent formatting. You can check whether the code is formatted
correctly using:

```
$ pipenv run black --check src/ tests/
```

Black will even fix your formatting for you! Just omit the `--check`
flag from the command above. To run black, you need to have installed
all required libraries first using `pipenv install`.

### CI/CD Details

We use a git branching model, where `master` represents the current
stable version, `develop` represents the current beta version, and
feature development happens in feature branches, typically named after
Jira tickets, such as `MDS-123`. When starting on a new feature,
typically you will branch from `develop`. Once feature development is
complete, create a merge request to `develop`. That will trigger
Gitlab CI to run the test cases and check the code formatting. Only if
everything looks good will you be able to merge into develop
(actually; you can override these constraints if you really want to
and merge into develop even without the test cases passing, but you
should typically not do this). Assuming the test cases pass and the
code is formatted correctly, the Docker image will be built and sent
to AWS EC2 Container Repository, tagged as `alive_or_dead:staging`.
Thus, every merge request to `develop` that passes will update the
`staging` environment, even without technically completing the merge.

When we are ready to release a new stable version, simply create a
merge request from `develop` to `master`. That will again run the test
cases. Unlike with `staging`, to deploy to prod you need to manually
start the `deploy to prod` job after the test cases pass. You can do
so from the merge request UI, or from the `CI/CD` menu on the left of
Gitlab. That will send the Docker image to ECR labeled as
`alive_or_dead:latest`.

## Staging and Production Environments

The Alive/Dead segmentation is run using AWS Data Pipeline. There are
staging and prod versions of these data pipelines running based on the
`staging` and `latest` tagged Docker images, respectively. They both
run daily. The configurations of those data pipelines are in the
`etc/` folder of this repository. If they need to be updated for
whatever reason, you'll need to delete and recreate the
pipelines. That can be done from within Gitlab itself, in a similar
way as deploying to prod. There are jobs for recreating either the
staging or prod data pipelines, accessible either from the merge
request UI or from the `CI/CD` menu on the left of Gitlab. This would
typically be done less often than deploying to prod. You might also do
this to manually trigger a run, since there's not a great way to
trigger the pipeline manually. Just delete and recreate the pipeline
and it will run right away.


## Models Used

*  Datat Input: Recency-Frequency-Monetary (RFM) model
*  Prediction Method: BG/BB (Beta Geometric/Beta Binomial) model
*  Parameter Esimation: Maximum Likelihood Estimation (MLE) 
*  Optimization Method: Simplex Method (i.e. Nelder-Mead) and Bound-Constrained Minimization Method (i.e. L-BFGS-B, trust-constr).
 

At a high level, the model is known as BGBB (Beta Geometric/Beta
Binomial) model.Heterogeneity in both the transaction and drop-out
rates is captured by beta distributions. Geometric distribution
captures the 'drop-out' phenomenon of the customer while the
transaction making phenomenon is captured by a binomial distribution.

To accomplish Objective #1, we use the "buy till you die" methodology
as discussed in [FHS:10].

* Transaction and Drop-out Processes:
The setting includes transaction opportunities that occur at even
spacings, e.g. weekly. At each opportunity, a person buys with a
certain probability, p.  At some point they "die", after which they
never purchase again. A person dies at each transaction opportunity
with a certain probability θ. Different people will have their own
"buy" and "die" probabilities, but across the population it is assumed
that p and θ follow Beta distributions. A Beta distribution is
characterized by two parameters.For the "buy" distribution, these
parameters are α and β; for the "die" distribution, these parameters
are γ and δ.  Fitting the BG/BB model is a maximum likelihood
estimation procedure that results in estimates of α, β, γ and δ.

* Dead or Alive Prediction:
    * Please refer to [Wil:19] for a detailed description of the Dead/Alive prediction calculation.

Notably, we assumed that customers made their first purchase at the
same time follows the same transaction and drop-out processes, meaning
that same cohort (customers have their first purchase in January 2015)
will have the same α, β, γ and δ parameters.  And their individual
purchase patterns (Recency-Frequency combination) determine their , so
that if a customer A has the same most recent purchase as customer B,
and the same number of transactions, no matter when their other
purchases occurred, they will have the same parameters p and θ. We are
aware of that some other models with a Markov-Chain Monte-Carlo
process will give us customer level parameters generated.


## References
[FHS:10] Peter S. Fader, Bruce G. S. Hardie, and Jen Shang, "[Customer-Base Analysis in a Discrete-Time Noncontractual Setting](http://www.brucehardie.com/papers/020/fader_et_al_mksc_10.pdf)". Marketing Science Vol. 29 No. 6, 2010. <br />
[Fad:18] Peter S. Fader, "tests/resources/HW6_2018_Spreadsheet_Solutions.xlsx". 2018. <br />
[Wil:19] Bob Wilson, "[BG/BB and Alive/Dead](https://confluence.livenation.com/pages/viewpage.action?pageId=172287515)"
