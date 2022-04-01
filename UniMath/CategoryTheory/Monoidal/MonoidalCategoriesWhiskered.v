Require Import UniMath.Foundations.All.
Require Import UniMath.CategoryTheory.Core.Categories.
Require Import UniMath.CategoryTheory.Core.Functors.
Require Import UniMath.CategoryTheory.Core.NaturalTransformations.
Require Import UniMath.CategoryTheory.Core.Isos.
Require Import UniMath.CategoryTheory.Monoidal.WhiskeredBifunctors.

Local Open Scope cat.

Import BifunctorNotations.

(** Data **)
Definition tensor (C : category) : UU :=
  bifunctor C C C.
Identity Coercion tensorintobifunctor : tensor >-> bifunctor.

Definition associator_data {C : category} (T : tensor C) : UU :=
  ∏ (x y z : C), C ⟦(x ⊗_{T} y) ⊗_{T} z, x ⊗_{T} (y ⊗_{T} z)⟧.

Definition leftunitor_data {C : category} (T : tensor C) (I : C) : UU :=
  ∏ (x : C), C⟦I ⊗_{T} x, x⟧.

Definition nattransdata_from_leftunitordata {C : category} {T : tensor C} {I : C} (lu : leftunitor_data T I):
  nat_trans_data (leftwhiskering_functor T (bifunctor_leftid T) (bifunctor_leftcomp T) I) (functor_identity C).
Proof.
  exact (λ x, lu x).
Defined.

Definition rightunitor_data {C : category} (T : tensor C) (I : C) : UU :=
  ∏ (x : C), C⟦x ⊗_{T} I, x⟧.

Definition nattransdata_from_rightunitordata {C : category} {T : tensor C} {I : C} (ru : rightunitor_data T I) :
  nat_trans_data (rightwhiskering_functor T (bifunctor_rightid T) (bifunctor_rightcomp T) I) (functor_identity C).
Proof.
  exact (λ x, ru x).
Defined.

Definition monoidal_data (C : category): UU :=
    ∑ T : tensor C, ∑ I : C,
        (leftunitor_data T I) × (rightunitor_data T I) × (associator_data T).

Definition make_monoidal_data {C : category} {T : tensor C} {I : C} (lu : leftunitor_data T I) (ru : rightunitor_data T I) (α : associator_data T) : monoidal_data C := (T,,I,,lu,,ru,,α).

Definition monoidal_tensor {C : category} (MD : monoidal_data C) : tensor C := (pr1 MD).
Coercion monoidal_tensor : monoidal_data >-> tensor.

Definition monoidal_unit {C : category} (MD : monoidal_data C) : C := (pr1 (pr2 MD)).
Notation "I_{ MD }" := (monoidal_unit MD).

Definition monoidal_leftunitordata {C : category} (MD : monoidal_data C) : leftunitor_data MD I_{MD} := (pr1 (pr2 (pr2 MD))).
Notation "lu_{ MD }" := (monoidal_leftunitordata MD).

Definition monoidal_rightunitordata {C : category} (MD : monoidal_data C) : rightunitor_data MD I_{MD} := (pr1 (pr2 (pr2 (pr2 MD)))).
Notation "ru_{ MD }" := (monoidal_rightunitordata MD).

Definition monoidal_associatordata {C : category} (MD : monoidal_data C) : associator_data MD := (pr2 (pr2 (pr2 (pr2 MD)))).
Notation "α_{ MD }" := (monoidal_associatordata MD).

(** Axioms **)
Definition associator_nat_leftwhisker {C : category} {T : tensor C} (α : associator_data T) : UU
  := ∏ (x y z z' : C) (h : C⟦z,z'⟧),
    (α x y z) · (x ⊗^{ T}_{l} (y ⊗^{ T}_{l} h)) = ((x ⊗_{ T} y) ⊗^{ T}_{l} h) · (α x y z').

Definition associator_nat_rightwhisker {C : category} {T : tensor C} (α : associator_data T) : UU
  := ∏ (x x' y z : C) (f : C⟦x,x'⟧),
    (α x y z) · (f ⊗^{ T}_{r} (y ⊗_{ T} z)) = ((f ⊗^{ T}_{r} y) ⊗^{ T}_{r} z) · (α x' y z).

Definition associator_nat_leftrightwhisker {C : category} {T : tensor C} (α : associator_data T) : UU
  := ∏ (x y y' z : C) (g : C⟦y,y'⟧),
       (α x y z) · (x ⊗^{ T}_{l} (g ⊗^{ T}_{r} z)) = ((x ⊗^{ T}_{l} g) ⊗^{ T}_{r} z) · (α x y' z).

Lemma associator_nat1 {C : category} {T : tensor C} {α : associator_data T} (αnl : associator_nat_leftwhisker α) (αnr : associator_nat_rightwhisker α) (αnlr : associator_nat_leftrightwhisker α) {x x' y y' z z' : C} (f : C⟦x,x'⟧) (g : C⟦y,y'⟧) (h : C⟦z,z'⟧) :
       (α x y z) · ((f ⊗^{ T}_{r} (y ⊗_{ T} z)) · (x' ⊗^{ T}_{l} ((g ⊗^{ T}_{r} z) · (y' ⊗^{ T}_{l} h)))) =
         (((f ⊗^{ T}_{r} y) · (x' ⊗^{ T}_{l} g))  ⊗^{ T}_{r} z) · ((x' ⊗_{ T} y') ⊗^{ T}_{l} h) · (α x' y' z').
Proof.
  rewrite assoc.
  rewrite αnr.
  rewrite assoc'.
  etrans. {
    apply cancel_precomposition.
    rewrite (bifunctor_leftcomp T).
    rewrite assoc.
    rewrite αnlr.
    apply idpath.
  }

  etrans. {
    apply cancel_precomposition.
    rewrite assoc'.
    apply cancel_precomposition.
    apply αnl.
  }
  rewrite assoc.
  rewrite assoc.
  apply cancel_postcomposition.
  apply pathsinv0.
  rewrite bifunctor_rightcomp.
  apply idpath.
Qed.

Lemma associator_nat2 {C : category} {T : tensor C} {α : associator_data T} (αnl : associator_nat_leftwhisker α) (αnr : associator_nat_rightwhisker α) (αnlr : associator_nat_leftrightwhisker α)
      {x x' y y' z z' : C} (f : C⟦x,x'⟧) (g : C⟦y,y'⟧) (h : C⟦z,z'⟧) :
    (f ⊗^{T} (g ⊗^{T} h))∘(α x y z) = (α x' y' z')∘ ((f ⊗^{T} g) ⊗^{T} h).
Proof.
  intros.
  unfold functoronmorphisms1.
  exact (associator_nat1 αnl αnr αnlr f g h).
Qed.

Definition associator_iso {C : category} {T : tensor C} (α : associator_data T) : UU :=
  ∏ (x y z : C), is_z_isomorphism (α x y z).

Definition associator_law {C : category} {T : tensor C} (α : associator_data T) : UU :=
  (associator_nat_leftwhisker α) × (associator_nat_rightwhisker α) × (associator_nat_leftrightwhisker α) × (associator_iso α).

Definition associatorlaw_natleft {C : category} {T : tensor C} {α : associator_data T} (αl : associator_law α) : associator_nat_leftwhisker α := pr1 αl.
Definition associatorlaw_natright {C : category} {T : tensor C} {α : associator_data T} (αl : associator_law α) : associator_nat_rightwhisker α := pr1 (pr2 αl).
Definition associatorlaw_natleftright {C : category} {T : tensor C} {α : associator_data T} (αl : associator_law α) : associator_nat_leftrightwhisker α := pr1 (pr2 (pr2 αl)).
Definition associatorlaw_iso {C : category} {T : tensor C} {α : associator_data T} (αl : associator_law α) : associator_iso α := pr2 (pr2 (pr2 αl)).

Definition leftunitor_nat {C : category} {T : tensor C} {I : C} (lu : leftunitor_data T I) : UU :=
  ∏ (x y : C), ∏ (f : C ⟦x,y⟧),  I ⊗^{ T}_{l} f · lu y = lu x · f.

Lemma leftunitor_nattrans {C : category} {T : tensor C} {I : C} {lu : leftunitor_data T I} (lunat : leftunitor_nat lu):
  nat_trans (leftwhiskering_functor T (bifunctor_leftid T) (bifunctor_leftcomp T) I) (functor_identity C).
Proof.
  use make_nat_trans.
  - exact (nattransdata_from_leftunitordata lu).
  - exact (λ x y f, lunat x y f).
Defined.

Definition leftunitor_iso {C : category} {T : tensor C} {I : C} (lu : leftunitor_data T I) : UU :=
  ∏ (x : C), is_z_isomorphism (lu x).

Definition leftunitor_law {C : category} {T : tensor C} {I : C} (lu : leftunitor_data T I) : UU :=
  leftunitor_nat lu × leftunitor_iso lu.

Definition leftunitorlaw_nat {C : category} {T : tensor C} {I : C} {lu : leftunitor_data T I} (lul : leftunitor_law lu) : leftunitor_nat lu := pr1 lul.

Definition leftunitorlaw_iso {C : category} {T : tensor C} {I : C} {lu : leftunitor_data T I} (lul : leftunitor_law lu) : leftunitor_iso lu := pr2 lul.

Definition rightunitor_nat {C : category} {T : tensor C} {I : C} (ru : rightunitor_data T I) : UU :=
  ∏ (x y : C), ∏ (f : C ⟦x,y⟧),  f ⊗^{ T}_{r} I · ru y = ru x · f.

Definition rightunitor_nattrans {C : category} {T : tensor C} {I : C} {ru : rightunitor_data T I} (runat : rightunitor_nat ru) :
  nat_trans (rightwhiskering_functor T (bifunctor_rightid T) (bifunctor_rightcomp T) I) (functor_identity C).
Proof.
  use make_nat_trans.
  - exact (nattransdata_from_rightunitordata ru).
  - exact (λ x y f, runat x y f).
Defined.

Definition rightunitor_iso {C : category} {T : tensor C} {I : C} (ru : rightunitor_data T I) : UU :=
  ∏ (x : C), is_z_isomorphism (ru x).

Definition rightunitor_law {C : category} {T : tensor C} {I : C} (ru : rightunitor_data T I) : UU :=
  rightunitor_nat ru × rightunitor_iso ru.

Definition rightunitorlaw_nat {C : category} {T : tensor C} {I : C} {ru : rightunitor_data T I} (rul : rightunitor_law ru) : rightunitor_nat ru := pr1 rul.

Definition rightunitorlaw_iso {C : category} {T : tensor C} {I : C} {ru : rightunitor_data T I} (rul : rightunitor_law ru) : rightunitor_iso ru := pr2 rul.

Definition triangle_identity {C : category}
           {T : tensor C}
           {I : C}
           (lu : leftunitor_data T I)
           (ru : rightunitor_data T I)
           (α : associator_data T)
    := ∏ (x y : C), (α x I y) · (x ⊗^{T}_{l} (lu y)) = (ru x) ⊗^{T}_{r} y.

Definition pentagon_identity {C : category} {T : tensor C} (α : associator_data T) : UU :=
  ∏ (w x y z : C),
    ((α w x y) ⊗^{T}_{r} z)·(α w (x⊗_{T} y) z)·(w ⊗^{T}_{l} (α x y z)) =  (α (w⊗_{T}x) y z)·(α w x (y ⊗_{T} z)).

Definition monoidal_laws {C : category} (MD : monoidal_data C) : UU :=
   (associator_law α_{MD}) × (leftunitor_law lu_{MD}) × (rightunitor_law ru_{MD})
                       × (triangle_identity lu_{MD} ru_{MD} α_{MD}) × (pentagon_identity α_{MD}).

Definition monoidal (C : category) : UU :=
  ∑ (MD : monoidal_data C), (monoidal_laws MD).

Definition monoidal_mondata {C : category} (M : monoidal C) : monoidal_data C := pr1 M.
Coercion monoidal_mondata : monoidal >-> monoidal_data.

Definition monoidal_monlaws {C : category} (M : monoidal C) : monoidal_laws M := pr2 M.

Definition monoidal_associatorlaw {C : category} (M : monoidal C) : associator_law α_{M} := pr1 (monoidal_monlaws M).
Definition monoidal_leftunitorlaw {C : category} (M : monoidal C) : leftunitor_law lu_{M} := pr1 (pr2 (monoidal_monlaws M)).
Definition monoidal_rightunitorlaw {C : category} (M : monoidal C) : rightunitor_law ru_{M} := pr1(pr2 (pr2 (monoidal_monlaws M))).
Definition monoidal_triangleidentity {C : category} (M : monoidal C) : triangle_identity lu_{M} ru_{M} α_{M} := pr1 (pr2 (pr2 (pr2 (monoidal_monlaws M)))).
Definition monoidal_pentagonidentity {C : category} (M : monoidal C) : pentagon_identity α_{M} := pr2 (pr2 (pr2 (pr2 (monoidal_monlaws M)))).

Definition monoidal_leftassociator {C : category} (M : monoidal C) (x y z: C) := pr1 (associatorlaw_iso (monoidal_associatorlaw M) x y z).

Lemma pentagon_identity_leftassociator {C : category} (M : monoidal C)(w x y z : C):
  w ⊗^{ M}_{l} (monoidal_leftassociator M x y z)
  ·  monoidal_leftassociator M w (x ⊗_{ M} y) z
  ·  monoidal_leftassociator M w x y ⊗^{ M}_{r} z =
   monoidal_leftassociator M w x (y ⊗_{ M} z)
  · monoidal_leftassociator M (w ⊗_{ M} x) y z.
Proof.
  Admitted.

Module MonoidalNotations.
  Notation "I_{ M }" := (monoidal_unit M).
  Notation "lu^{ M }" := (monoidal_leftunitordata M).
  Notation "ru^{ M }" := (monoidal_rightunitordata M).
  Notation "α^{ M }" := (monoidal_associatordata M).
  Notation "lu^{ M }_{ x }" := (monoidal_leftunitordata M x ).
  Notation "ru^{ M }_{ x }" := ( monoidal_rightunitordata M x ).
  Notation "α^{ M }_{ x , y , z }" := (monoidal_associatordata M x y z).
End MonoidalNotations.
