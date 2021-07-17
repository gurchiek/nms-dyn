function [df_dlm,df_dvm] = muscleTendonEquilibriumJacobian(t,lm,vm,muscle,time)

[~,df_dlm,df_dvm] = muscleTendonEquilibrium(t,lm,vm,muscle,time);

end