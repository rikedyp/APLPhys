:Namespace Particles
    ⎕DIV←1   
    ⍝ LJ testing
    ⍝0.1 1 #.Particles.(1 1 LJ Grid VVerlet)⍣2⊢#.Testing.(r v f)
    Table←{⍺⍺⍤1 99⍨⍵}
    Abs←{0.5*⍨+/⍵*2}
    Hooke←{⍺⍺×⍵-⍵[2;2]} ⍝ Hooke's law between nearest neighbours
    ⍝LJ←{d←Abs↑r←⍵-⍵[2;2] ⋄ r×(48×⍺⍺[1]÷d*2)×(12*⍨⍺⍺[2]÷d)-0.5×(6*⍨⍺⍺[2]÷d)} ⍝ Lennard-Jones between nearest neighbours
    LJ←{d←Abs↑r←⍵-⍵[2;2] ⋄ r×(⍺⍺[1]×(2*d*¯13)-(d*¯7))} ⍝ Lennard-Jones between nearest neighbours
    Grid←{(+/∘,↓∘⍺⍺)⌺3 3⊢⍵} ⍝ Apply force to nearest neighbours in a square grid
    CreateAtoms←{
      boxdim←⍺ 
      type len←⍵
      type≡'hex':dx dy←len×(1 2)∘.○○30÷180 ⍝ 2D Hexagonal lattice

    }   
    HexLat←{
      boxdim←⍺
      len←⍵
      dx dy←len×(1 2)∘.○○30÷180 ⍝ Relative lattice positions
      dx dy×⍤1⊢↑,⍳boxdim
    }
      CalculateTemp←{
          dim←≢boxdim←⍺
          vel←⍵
          real_vel←boxdim×⍤1⊢vel
          ene_kin←0.5×+/,real_vel*2 ⍝ 0.5×v*2
          ene_kin_avg←ene_kin÷n
          temp←2×ene_kin_avg÷dim                              
          ⍝ TODO: Why ↓ needs n-1?
          temp←(dim×n-1)÷⍨+/,real_vel*2 ⍝ n-1 to match LAMMPS 
          ene_kin_avg temp
      }
      ComputeForcesLJ←{
          ⍝(boxdim epsilon rcutoff phicutoff)←⍺
          ⍝ pos←⍵
          dim←≢boxdim
          n←≢⍵
          ⍝ Relative displacement between pairs of particles
          ⍝S←∘.-⍨↓pos ⍝ TODO is there a less expensive way to do this?
          S←-⍤1 Table ⍵ ⍝ Table operator
          ⍝ If distance > 0.5, subtract 0.5 to find periodic interaction distance
          ⍝ TODO surely a way to do this using just mod?
          ⍝S←(⊢-×)@(⍸0.5≤|S)⊢S
          ⍝S-←(××0.5≤|)S
          S-←((0.5∘<)-(¯0.5∘>))S
          R←S×⍤1⊢boxdim ⍝ Scale to reduced LJ units        
          ⍝ Calculate potential inside cutoff
          Rmask←(rcutoff*2)>Rsq←+/R*2
          (1 1⍉Rmask)←0
          calcpos←1+(⍴Rmask)⊤¯1+⍸,Rmask ⍝ ≡ ↑⍸Rmask
          Rcalcsq←(,Rmask)⌿,[1 2]Rsq
          rm2←÷Rcalcsq⍝←+/Rcalc*2
          rm6←rm2*3
          rm12←rm6*2
          phi←epsilon×4×(rm12-rm6)-phicutoff
          dphi←epsilon×24×rm2×(2×rm12)-rm6
          ene_pot←+/0.5×phi
          virial←-+/dphi×Rcalcsq
          ⍝ Accumulate acceleration
          ⍝ ↓↓↓ Double check this ↓↓↓
          acc←n dim⍴0
          ⍝acc[∪⊃¨calcpos]←+/(dphi×⍤¯1⊢calcpos⌷⍤1 99⊢S){⍺⍺[⍵]}⌸⊣/calcpos ⍝ Accelerations by pairwise potentials
          ⍝acc[∪ids;]←+/[2](dphi×⍤¯1⊢calcpos⌷⍤1 99⊢S)⌷⍤0 99⍨{⊂⍵}⌸ids←⊣/calcpos
⍝          acc[∪ids;]←+/¨(dphi×⍤¯1⊢calcpos⌷⍤1 99⊢S)⊆[1]⍨ids←⊣/calcpos
          t0←(1+(≢S)⊥¯1+calcpos)⌷⍤0 99⊢((2*⍨≢S),dim)⍴S
          ⍝t0←calcpos⌷⍤1 99⊢S
          t1←dphi×⍤1⍉t0
          t2←⍉t1(+/¨⊂)⍤1⍨2≠/¯1,ids←⊣⌿calcpos
          acc[∪ids;]←t2
          ⍝acc[∪ids;]←⍉(dphi×⍤1⍉calcpos⌷⍤1 99⊢S)(+/¨⊂)⍤1⍨2≠/¯1,ids←⊣/calcpos
          ⍝acc[∪⊃¨calcpos]←+/(dphi×S[calcpos]){⍺⍺[⍵]}⌸⊃¨calcpos ⍝ Accelerations by pairwise potentials
          acc(ene_pot÷n)(-virial÷dim) ⍝ TODO either all necessary as input or constants as global
      }
      VVerlet←{(dt m)(r v f)←⍺ ⍵
          ⍝ Velocity Verlet integrator
          ⍝ Left: Time step and mass
          ⍝ Right: Position r, velocity v, force-per-particle f
          vhalf←v+dt×f÷2×m
          rnew←r+vhalf×dt
          fnew←↑,⍺⍺{(2/0.5*⍨≢⍵)⍴↓⍵}rnew
          vnew←vhalf+dt×fnew÷2×m
          ⍝rnew←20|rnew⍝ Periodic boundary conditions
          rnew vnew fnew
      }
    ∇ log←params LJMelt state
      ⍝⎕FR←1287
      (boxdim n epsilon rcutoff dt T)←params
      (pos vel acc)←state
      phicutoff←-/4÷rcutoff*12 6
      volume←×/boxdim
      density←n÷volume ⍝ TODO these are constants
      ⍝(pos vel acc)←¯0.5+?3⍴⊂n dim⍴0 ⍝ Random initial conditions
      ⍝:for i :in ⍳nsteps ⍝ TODO RECURSIVE VERSION
      ⍝pos←¯0.5+1|0.5+pos ⍝ Fold positions
      pos←1|pos ⍝ Fold positions
      pos+←dt×vel+0.5×acc×dt ⍝ Step positions
      ene_kin_avg temp←boxdim CalculateTemp vel
      chi←0.5*⍨T÷temp ⍝ Rescale vel (Berendsen thermosts I think)
      vel←(chi×vel)+0.5×dt×acc ⍝ v(t+dt÷2)
      ⍝ Quite long? ↓↓↓↓↓↓↓↓↓
      (acc ene_pot_avg virial)←(boxdim epsilon rcutoff phicutoff)ComputeForcesLJ pos
      vel+←0.5×dt×acc ⍝ Complete step
     
      ene_kin_avg temp←boxdim CalculateTemp vel
      pressure←(density×temp)+virial÷volume
     
      log←pos vel acc ene_kin_avg ene_pot_avg temp pressure
     
      ⍝:Endfor
    ∇


:Endnamespace
