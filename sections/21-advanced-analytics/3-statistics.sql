use schema employees.public;

-- skew & kurtosis
select count(*), avg(sal), median(sal),
  skew(sal), kurtosis(sal)
from emp;

-- linear regression
select REGR_SLOPE(sals, year), 
  REGR_INTERCEPT(sals, year),
  REGR_R2(sals, year)
from (
  select year(hiredate) as year, sal as sals
  from emp
  order by year
);
