:Namespace Overrides

    ∇ Make config
      :Access Public
  ⍝    :Implements Constructor :Base config
      ⍝ TODO Config file ↓↓
      #.APLPhysPath←'C:\Users\rpark\Documents\APL\Projects\APLPhys\APLPhys'
    ∇

    ∇ onServerStart
      #.APLPhysPath←'C:\Users\rpark\Documents\APL\Projects\APLPhys\APLPhys'
      ⎕←'Initialising APLPhys...'
      ⎕SE.Link.Create'#.APLPhys'#.APLPhysPath
      #.APLPhys.Init
      ⎕←'APLPhys loaded.'
    ∇

    ∇ onSessionStart req
      ⍝:Access public override
      ⍝ Maybe reset stuff on server start
      ⎕←'Session started at ',⎕TS
    ∇

:EndNamespace
