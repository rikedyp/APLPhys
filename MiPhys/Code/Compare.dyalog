:Namespace Compare
    ∇ dump←args LoadDump file;mask
      type←⊃args
      :If type≡'LAMMPS'
          natoms nsteps←1↓args
          dump←⊃⎕NGET file 1
          mask←∊nsteps⍴⊂(9⍴0),natoms⍴1
          dump←mask⌿dump
      :ElseIf type≡'python'
      :ElseIf type≡'FORTRAN'
      :ElseIf type≡'APL'
          natoms nsteps←1↓args
          dump←⊃⎕NGET file 1
          mask←∊nsteps⍴⊂(8⍴0),natoms⍴1
          dump←mask⌿dump
      :Else
          ⎕SIGNAL 11
      :EndIf
    ∇
    ∇ pos←dim Process dump
      pos←5⍕⍎¨(≢dump)dim↑' '(≠⊆⊢)⍤1⊢↑dump
    ∇
:Endnamespace
