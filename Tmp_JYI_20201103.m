% J = MixMat*vload;
% figure; hold on;
% plot(J,'*');
% plot(poolVload,'o');
% legend('Est','Tru')

Evidence for choosing threshold for early stopping in exhaustive search
- for MHV1_2 with mixing matrix 4 by 15:
  (1) run 1, relative residual e-6;
  (2) run 2, relative residual for {2,3} e-9; 
             relative residual for 2, or 3, or 6, e-1
  (3) run 3, relative residual e-6
  (4) run 4, relative residual for 2, or 3, e-1
             relative residual for {2,3}, e-7

%%
Unfortunately, at present, we have to write the system in the way as it is. As I observe from our experiences in the past, we frequently change our minds, and have many expectations of the functionalities it can perform. We can definitely make a copy for each run, i.e., run 1 and run 2; we can also make a copy for each functionality we want to achieve. It's totally fine, but we will end up with too many copies of the codes. I'm not sure how you feel when you create one copy of the script for run of the experiment, whether you want to spend the time to manage so many files, and whether you will be patient enough to open 2^n files and run the codes for 2^n times. 