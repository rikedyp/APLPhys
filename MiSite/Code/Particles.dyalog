:Namespace Particles

    HookeGrid←{⍺⍺{+/,⍺⍺×⍺↓⍵-⍵[2;2]}⌺3 3⊢⍵} ⍝ Hooke's law on neighbours in square grid
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
