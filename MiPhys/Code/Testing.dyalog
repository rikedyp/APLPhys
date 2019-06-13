:Namespace Testing
    ⍝ Optional constants
    ⍝ ------------------
    ∇ Init
      ⍝#.⎕FR←1287
      ⍝#.⎕PP←34
      ⍝#.⎕CT←1e¯14
      PP←6
      n←3000 ⍝ Number of atoms
    ⍝ TODO: box dimension / lattice vector to create particles
      dt←0.0032
      dumpfreq←100
      epsilon←1
      rcutoff←2.5
      boxdim←100 100
      T←0.5
    ⍝ Derived constants
    ⍝ -----------------
      dim←≢boxdim
      phicutoff←-/4÷rcutoff*12 6
      volume←×/boxdim
      density←n÷volume
      ⎕RL←123  
      ⍝pos←↑,¯0.1+(boxdim÷n)×32×⍳dim/⌈n*0.5
      pos←?n dim⍴0 ⍝ Random initial positions
      ⍝pos←n dim↑0 LoadState'./LAMMPS/LJmelt/start50.pos'
      ⍝pos←boxdim÷⍨⍤1⊢pos ⍝ Box scaled units 
      ⎕RL←123
      vel←¯0.5+?n dim⍴0 ⍝ Random initial velocities
      ⍝vel←n dim↑0 LoadState'./LAMMPS/LJmelt/start50.vel'
      ⍝vel←boxdim÷⍨⍤1⊢vel
      ⍝acc←n dim⍴0 ⍝ No initial acceleration
      p←#.Particles
      p.(boxdim dim phicutoff rcutoff epsilon)←boxdim dim phicutoff rcutoff epsilon
      (acc ene_pot_avg virial)←p.ComputeForcesLJ pos
    ∇

    ∇ state←drop LoadState file
      ⍝⎕FR←1287
      ⍝⎕PP←34
      state←⊃⎕NGET file 1
      state←⍎¨' '(≠⊆⊢)⍤1⊢drop↓[⎕IO+1]↑state
    ∇

    ∇ tmp←dim GetTmp file
      tmp←{(≢⍵)dim↑⍵}⍎¨' '(≠⊆⊢)⍤1⊢↑('-'⎕R'¯')⊃⎕NGET file 1
    ∇

    ∇ i PrintStep log;state
      printstep←'ene_kin_avg' 'ene_pot_avg' 'temperature' 'pressure',⍪3↓log
      state←↓[1]⍉boxdim×⍤1⊢↑2↑log
      ⍝state←boxdim×⍤1⊢↑⊃log
      printstep←⍕⍪(⊂'')⍪(⊂'Step: ',i)⍪(⊂'')⍪(⊂printstep)⍪(⊂'')⍪⊂PP⍕¨⊆state
      (⊂↓printstep)⎕NPUT'./traj/traj.xyz' 2 ⍝ Append log to file
    ∇

    ∇ pos←l HexLattice(min max);v
      v←l×1 2∘.○○30÷180 ⍝ Always 30?
      ⍝ pos,←⊂pos+⍤1⊢v
      ⍝(5 5⍴1 0)×(⊂v)×¨⍳5 5
      ⍝(25⍴1 0)⌿v×⍤1⊢↑,⍳5 5
      ⍝pos←min+⍤1⊢v{(1 0⍴⍨×/⍵)⌿⍺×⍤1⊢↑,⍳⍵}max-min
      pos←{⍵⌿⍨⍱/⍵>15}min+⍤1⊢v{(1 0⍴⍨×/⍵)⌿⍺×⍤1⊢↑,⍳⍵}⌈l÷⍨2×max-min
      ⍝ ⍉(2×v)(⊢,+)⍤1⊢↑1 1⍉(⊂v)×¨¯1+⍳2 2
    ∇

    ∇ {log}←Main nsteps;i;j;mylog;printstep;header ⍝ TODO general options right arg
      Init
      log←pos vel acc ⍬ ⍬ ⍬ ⍬
      j←0
      0 PrintStep log
      :For i :In ⍳nsteps
          mylog←(boxdim n epsilon rcutoff dt T)p.LJMelt pos vel acc
          (pos vel acc)←3↑mylog
          ⍝ Print log to file every dumpfreq steps
          ⍝:If 0=1|i
          ⍝    ⎕←¯3↑mylog
          ⍝:EndIf
          :If 0=dumpfreq|i
     
              i PrintStep mylog
              ⍝header←'n',⍨dim↑'xyz'
              ⍝(header⍪(¯1+⍳≢⊃mylog),⍨n dim↑⊃mylog)⎕CSV⍠'IfExists' 'Replace'⊢'traj/testtmp/traj.csv.',⍕j
              ⍝j+←1
          :EndIf
      :EndFor
    ∇
:EndNamespace
