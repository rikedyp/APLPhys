 {log}←Main nsteps;rcutoff;phicutoff;dim;n;boxdim;volume;density;nsteps;dumpfreq;dt;T;pos;vel;acc;S;i;R;Rcalc;calcpos;epsilon;Rsq;rm2;rm6;rm12;phi;dphi;ene_pot;virial;Rcalcsq;real_vel;ene_kin;ene_kin_avg;temp;chi;pressure

 log←⍬

 ⍝ Subroutines
 CalculateTemp←{
     dim←≢boxdim←⍺
     vel←⍵
     real_vel←boxdim×⍤1⊢vel
     ene_kin←+/0.5×+/real_vel*2 ⍝ 0.5×v*2
     ene_kin_avg←ene_kin÷n
     temp←2×ene_kin_avg÷dim
     ene_kin_avg temp
 }

 ComputeForces←{
     (boxdim epsilon rcutoff phicutoff)←⍺
     pos←⍵
 ⍝ Relative displacement between pairs of particles
     S←∘.-⍨↓pos ⍝ TODO is there a less expensive way to do this?
 ⍝ 0.5|∘.-⍨↓pos ⍝ Periodic interaction distances?
 ⍝ If distance > 0.5, subtract 0.5 to find periodic interaction distance
 ⍝ TODO surely a way to do this using just mod?
     S←↓{r←⍵ ⋄ (⊢-×)@(⍸0.5≤|⍵)⊢r}↑S
     R←S×⊂boxdim ⍝ Scale to reduced LJ units
   ⍝ Calculate potential inside cutoff
   ⍝ Ignore self      ↓↓↓↓↓↓↓↓↓
     Rcalc←R[calcpos←⍸(~∘.=⍨⍳n)×(rcutoff*2)>+/¨R*2]
     rm2←÷Rcalcsq←+/¨Rcalc*2
     rm6←rm2*3
     rm12←rm6*2
     phi←epsilon×4×(rm12-rm6)-phicutoff
     dphi←epsilon×24×rm2×(2×rm12)-rm6
     ene_pot←+/0.5×phi
     virial←-+/dphi×Rcalcsq
     ⍝ Accumulate acceleration
     ⍝ ↓↓↓ Double check this ↓↓↓
     acc←n⍴⊂0 0
     acc[∪⊃¨calcpos]←+/(dphi×S[calcpos]){⍺⍺[⍵]}⌸⊃¨calcpos ⍝ Accelerations by pairwise potentials
     acc←↑acc
     acc temp ene_pot virial
 }

 ⍝ Options
 ⍝ -------
 epsilon←1 ⍝ Potential well depth
 rcutoff←4.5 ⍝ Potential cutoff distance
 phicutoff←-/4÷rcutoff*12 6 ⍝ Potential shifting value (phi when r=0?)
 dim←2 ⍝ Dimensions
 n←10 ⍝ Number of particles
 boxdim←8 10 ⍝ Rectangular bounding box
 ⍝nsteps←10000
 dumpfreq←100 ⍝ How often to save data to log
 dt←0.0032 ⍝ Reduced time step
 T←0.5 ⍝ Thermostat temp in reduced temperature units

 ⍝ Set up
 ⍝ ------
 volume←×/boxdim
 density←n÷volume
 (pos vel acc)←¯0.5+?3⍴⊂n dim⍴0 ⍝ Random initial conditions

 ⍝ Run simulation
 ⍝ --------------
 ⍝ TODO Write program here
 ⍝ TODO Factor out dfns

 :For i :In ⍳nsteps

 ⍝ MAIN MD LOOP
 ⍝ ------------
 ⍝ Refold positions according to periodic boundary conditions
     pos←¯0.5+1|0.5+pos
 ⍝ TODO does boxdim matter? pos is scaled...
 ⍝ Step positions
     pos+←(dt×vel)+0.5×acc×dt*2 ⍝ Step 1
     ene_kin_avg temp←boxdim CalculateTemp vel ⍝ Calculate Temperature

 ⍝ Rescale velocities and take half step
     chi←0.5*⍨T÷temp
     vel←(chi×vel)+0.5×dt×acc ⍝ v(t+dt÷2)


 ⍝ COMPUTE FORCES
 ⍝ --------------
     (acc temp ene_pot virial)←(boxdim epsilon rcutoff phicutoff)ComputeForces pos

⍝ Complete velocity step
     vel+←0.5×dt×acc


     ene_kin_avg temp←boxdim CalculateTemp vel ⍝ Calculate Temperature

⍝ Calculate pressure
     pressure←(density×temp)+virial÷volume

⍝ Save to log every dumpfreq steps
     {0=dumpfreq|i:log,←⊂pos temp pressure}⍬


 :EndFor
