:Class APLPhysServer :MiServer

    ∇ Make config
      :Access Public
      :Implements Constructor :Base config
      ⍝ TODO Config file ↓↓
      APLPhysPath←'C:\Users\rpark\Documents\APL\Projects\APLPhys\APLPhys'
    ∇

    ∇ onServerStart
      :Access public override
      ⎕←'Initialising APLPhys...'
      ⎕SE.Link.Create'#.APLPhys'APLPhysPath
      #.APLPhys.Init
      ⎕←'APLPhys loaded.'
    ∇
    ∇ onSessionStart req
      :Access public override
      ⍝ Maybe reset stuff on server start
      ⎕←'Session started at ',⎕TS
    ∇

:EndClass
