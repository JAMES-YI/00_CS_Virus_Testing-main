function r = myfactorial(n)
   if n <= 0
     r = 1;
   else
     r = n * myfactorial(n-1);
   end
 end