:Namespace ParticlesOLD
    ⎕DIV←1  
    ⍝ LJ testing
    ⍝0.1 1 #.Particles.(1 1 LJ Grid VVerlet)⍣2⊢#.Testing.(r v f)
    Abs←{0.5*⍨+/⍵*2}
    Hooke←{⍺⍺×⍵-⍵[2;2]} ⍝ Hooke's law between nearest neighbours 
    LJ←{d←Abs↑r←⍵-⍵[2;2] ⋄ r×(48×⍺⍺[1]÷d*2)×(12*⍨⍺⍺[2]÷d)-0.5×(6*⍨⍺⍺[2]÷d)} ⍝ Lennard-Jones between nearest neighbours
    ⍝Grid←{⍺⍺{+/,⍺↓⍺⍺ ⍵}⌺3 3⊢⍵} ⍝ Apply force to nearest neighbours in a square grid
    Grid←{(+/∘,↓∘⍺⍺)⌺3 3⊢⍵} ⍝ Apply force to nearest neighbours in a square grid
    ⍝LJGrid←
      VVerlet←{ (dt m)(r v f)←⍺ ⍵ 
          ⍝ Velocity Verlet integrator 
          ⍝ Left: Time step and mass
          ⍝ Right: Position r, velocity v, force-per-particle f            
          vhalf←v+dt×f÷2×m
          rnew←r+vhalf×dt
          fnew←↑,⍺⍺{(2/0.5*⍨≢⍵)⍴↓⍵}rnew
          vnew←vhalf+dt×fnew÷2×m
          rnew vnew fnew
      }
:Endnamespace
