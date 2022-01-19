# A1GM
A1GM is an efficient rank-1 decomposition algorithm for non-negative matrix with missing values. 

* Ghalamkari, K., Sugiyama, M. : **Fast Rank-1 NMF for Missing Data with KL Divergence**, AISTATS 2022 (to appear). [[arXiv]](https://arxiv.org/abs/2110.12595)

## Requirements
A1GM is implemented in Julia 1.6.1.  
We need only `src/A1GM.jl` to run A1GM.
All other files are for experiments in our paper.

## Usage
The proposed algorithm A1GM is given in `src/A1GM.jl`.
The input is non-negative matrix `X` and binary weight `W`.
`W[i,j] = 0` if `X[i,j]` is missing value, otherwise `1`.
Note that A1GM does not requrie any hyper-paramters.
On the command line, we can use the algorithm as follows.
```julia
cd src
$ julia
julia> include("A1GM.jl")
julia> X = rand(4,4);
julia> W = [1 1 1 0; 1 1 1 1; 1 1 1 0; 0 1 1 1];
julia> R = A1GM(X, W)
```

The output `R` is a rank-1 non-negative matrix approximating `X`.
We can confirm its matrix rank by using `rank` in `LinearAlgebra`:
```julia
julia> using LinearAlgebra
julia> rank(R)
1
```

If we need factors instaed of reconstructed matrix, we can use `basis` option.
```julia
julia> A, B = A1GM(X,W,basis=true)
```
The reconstracted matrix `R` is the same as the Kronecker product of A and B,`kron(A,B)`. 
Note that if `W` is grid-like, `A1GM(X, W)` returns the best rank-1 approximation of `X`, minimizing the weighted KL divergence from `X`.
You can find the algorithm of A1GM in our paper.

## Closed formula of the best rank-1 NMMF
We also provide here the function `rank1_NMMF()` which finds the best rank-1 Non-Negative Multiple Matrix Factorization([NMMF](https://www.ijcai.org/Proceedings/13/Papers/254.pdf)). The solution formula is the theoretical contribution of our paper, and `A1GM` is an application of it.
```julia
function rank1_NMMF(X,Y,Z)
    sumZ2 = sum(Z,dims=2)
    sumY1 = sum(Y,dims=1)

    sumX = sum(X)
    sqrtsumX = sqrt(sumX)
    w = sqrt(sumX) / (sumX+sum(sumZ2)) .* ( sum(X,dims=2) + sumZ2 )
    a = sum(Y,dims=2) / sqrtsumX
    h = sqrt(sumX) / (sumX+sum(sumY1)) .* ( sum(X,dims=1) + sumY1 )
    b = sum(Z,dims=1) / sqrtsumX
    return w,h,a,b
end
```
This is an example of factor sharing decomposition of random matrices `X`, `Y` and `Z`.
```julia
$ julia
julia> X = rand(5,4); Y = rand(6,4); Z = rand(5,3);
julia> w,h,a,b = rank1_NMMF(X,Y,Z)
```
These factors, `w`,`h`,`a` and `b` globally minimize the weighted KL cost funtion which `kron(w,h)` approximates `X`, `kron(a,h)` approximates `Y` and `kron(w,b)` approximates `Z`. See more details in Theorem 1 in our paper.

## Experiments in the paper
Our experiments on synthetic datasets can be performed from the command line as follows.
```
$ julia run.jl
```

Results for synthetic datasets obtained by the above commands correspond to Fig. 5(a)(b) in our paper.
Results will be saved in `../result` as jld2 files.
​
 The following commands
```
cd plot
$ julia plot.jl
```
make png images from jld2 files. The generated pdf files will be saved in `/pngs`.
We can modify experimental conditions and plot conditions by editing the file `config.jl`.
​

For experiments with real datasets, real-world datasets have to be stored in `../../../datasets/matrix/` as jld2 files in advance. To access the files, `data_loader.jl` can be used.
​Please refer to the appendix for the information on how to obtain real datasets.


## Citation
If you use A1GM or the closed formula of the best rank-1 NMMF in a scientific publication, we would appreciate citations to the following paper:
* Ghalamkari, K., Sugiyama, M. : **Fast Rank-1 NMF for Missing Data with KL Divergence**, AISTATS 2022 (to appear).

Bibtex entry:
```
@inproceedings{Ghalamkari2022Fast,
    Author = {Ghalamkari, K. and Sugiyama, M.},
    Title = {Fast Rank-1 NMF for Missing Data with KL Divergence},
    Booktitle = {Proceedings of the 25th International Conference on Artificial Intelligence and Statistics},
    Pages = {XX--XX},
    Address = {Virtual Event},
    Month = {March},
    Year = {2022}}
```

## Contact
Author: Kazu Ghalamkari  
Affiliation: National Institute of Informatics, Tokyo, Japan  
E-mail: gkazu@nii.ac.jp  
URL: [gkazu.info](http://gkazu.info)
