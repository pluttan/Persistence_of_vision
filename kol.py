from numba import njit, prange
from time import time

@njit(fastmath=True, cache=True,parallel=True)
def codefast():
    
    n=1
    k=n
    p=n
    
    while True:
        p+=1
        k=p
        if k%2!=0:
            while k>=p:
                if k%2==0:k//=2
                else:k=(3*k+1)//2
        if p%1000000000==0:
            print(p,k)
            
codefast()