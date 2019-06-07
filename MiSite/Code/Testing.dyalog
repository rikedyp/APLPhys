:Namespace Testing
    ⍝ Optional constants
    ⍝ ------------------
    ∇ Init
      n←32000 ⍝ ~ Number in LAMMPS LJMelt
    ⍝ TODO: box dimension / lattice vector to create particles
      dt←0.0032
      dumpfreq←10
      epsilon←1
      rcutoff←4.5
      boxdim←10 10
      T←0.5
    ⍝ Derived constants
    ⍝ -----------------
      dim←≢boxdim
      phicutoff←-4/÷rcutoff*12 6
      volume←×/boxdim
      density←n÷volume
      pos←?n dim⍴0 ⍝ Random initial positions
      vel←¯0.5+?n dim⍴0 ⍝ Random initial velocities
      acc←n dim⍴0 ⍝ No initial acceleration
      p←#.Particles
    ∇
    ∇ {log}←Main nsteps;i;j;mylog;printstep ⍝ TODO general options right arg
      Init
      log←⍬
      j←0
      :For i :In ⍳nsteps
          mylog←(boxdim n epsilon rcutoff dt T)p.LJMelt pos vel acc
          (pos vel acc)←3↑mylog
          ⍝ Print log to file every dumpfreq steps
          :If 0=dumpfreq|i
              ⍝printstep←'ene_kin_avg' 'ene_pot_avg' 'temperature' 'pressure',⍪3↓mylog
              ⍝printstep←⍕⍪(⊂'')⍪(⊂'Step: ',i)⍪(⊂'')⍪(⊂printstep)⍪(⊂'')⍪⊂3↑mylog
              ⍝(⊂↓printstep)⎕NPUT'traj.xyz' 2 ⍝ Append log to file
              ('xyzn'⍪(¯1+⍳≢⊃mylog),⍨n dim↑⊃mylog)⎕CSV⍠'IfExists' 'Replace'⊢'traj/testtmp/traj.csv.',⍕j
              j+←1
          :EndIf
      :EndFor
    ∇
:EndNamespace
