# Montagem do Simulink — Questão 1 (Laboratório de Controle Discreto)

**Grupo:** Luiz E. Passoni de Souza / Victor Damasceno Oliveira
**Objetivo:** itens (c) e (d) da Questão 1 — montar o esquema de controle digital do motor DC e
comprovar o número de amostras calculado no item (b).

**Valores já calculados (itens a/b), use estes:**
- Planta contínua: `G(s) = 1 / (s² + 12 s + 20.05)`
- Período de amostragem: **T = 0.1369 s**
- Frequência natural da malha fechada: `ωn = 4.588 rad/s` → período natural `2π/ωn = 1.3695 s`
- Critério a comprovar no item (d): **~10 amostras** dentro de 1.3695 s

---

## 1. Topologia do modelo

```
                          MALHA DIGITAL (controlador)              PLANTA CONTÍNUA (motor)

 Step(ref=1) →(+)→[erro]→ ZOH(A/D) → D(z) → ZOH(D/A) →Va→(+)→[0.05/(s+2)]→Tm→(+)→[1/(0.05s+0.5)]→ω──┬──→ Scope
              (−)↑                                            (−)↑ armadura        (−)↑ mecânica      │
                 │                                               │                    │              │
                 │                                            [Kb=0.05]←──────────────┼──────────────┤  (FCEM, malha interna)
                 │                                                                    │              │
                 │                                                              Step(Td=0)           │
                 └────────────────────────── realimentação unitária (ω) ──────────────────────────--┘
```

Há **duas** realimentações:
- **interna** = FCEM `Kb` (faz parte do motor);
- **externa** = unitária da velocidade `ω` (a malha de controle).

---

## 2. Blocos a usar (Library Browser → onde achar)

| Bloco | Biblioteca | Função |
|---|---|---|
| `Step` | Sources | Referência e perturbação Td |
| `Sum` | Math Operations | Somadores (erro, Va, TL) |
| `Gain` | Math Operations | Ganho Kb |
| `Transfer Fcn` | Continuous | Armadura e mecânica |
| `Zero-Order Hold` | Discrete | A/D e D/A |
| `Discrete Transfer Fcn` | Discrete | Controlador D(z) |
| `Scope` / `Mux` | Sinks / Signal Routing | Visualizar |

---

## 3. Parâmetros de cada bloco

### Malha digital
- **Step (referência):** Step time = `0`, Final value = `1`
- **Sum (erro):** List of signs = `+-`
- **Zero-Order Hold (A/D):** Sample time = `0.1369`
- **Discrete Transfer Fcn — D(z):** Numerator = `[1]`, Denominator = `[1]`, Sample time = `0.1369`
  - Na **Questão 1, D(z) = 1** (placeholder). Os controladores são projetados na Questão 2.
- **Zero-Order Hold (D/A):** Sample time = `0.1369`

### Planta (motor) contínua
- **Sum1 (Va − Kb·ω):** signs = `+-`
- **Transfer Fcn (armadura):** Numerator = `[0.05]`, Denominator = `[1 2]`   → 0.05/(s+2)
- **Sum2 (Tm − Td):** signs = `+-`
- **Transfer Fcn (mecânica):** Numerator = `[1]`, Denominator = `[0.05 0.5]`  → 1/(0.05·s+0.5)
- **Gain (Kb):** valor = `0.05`
- **Step (Td):** Final value = `0`  (item (a) pede Td = 0; deixa pronto para a Q3, onde vira degrau aplicado após o regime)

---

## 4. Passo a passo de montagem

1. **Novo modelo:** Simulink → *Blank Model*. Salvar como `motor_Q1.slx`.
2. **Monte a planta** (parte contínua), da esquerda para a direita: `Sum1 → armadura → Sum2 → mecânica`. A saída da mecânica é `ω`.
3. **Feche a malha interna Kb:** puxe um ramo de `ω`, passe pelo `Gain` Kb = 0.05 e ligue na **2ª entrada (−)** do `Sum1`.
4. **Ligue Td:** `Step (Td)` → **entrada (−)** do `Sum2`.
5. **Monte a malha digital** à esquerda: `Step(ref) → Sum0 → ZOH(A/D) → D(z) → ZOH(D/A)`. A saída do ZOH(D/A) é `Va` → ligue na **entrada (+)** do `Sum1`.
6. **Feche a realimentação unitária:** puxe outro ramo de `ω` direto para a **2ª entrada (−)** do `Sum0`.
7. **Scopes:** ligue um `Scope` em `ω` (saída). Para o item (d), ligue **outro `Scope` na saída do ZOH(D/A)** — é nele que aparecem os degraus.
8. **Confira os sample times:** os três blocos discretos (2 ZOH + D(z)) devem estar todos com `0.1369`.

---

## 5. Parâmetros de simulação

- **Solver:** `ode45` (variable-step) — ok para mistura contínuo/discreto.
- **Stop time:** `3` s (o assentamento é ~1,9 s).
- Em *Model Settings → Solver*, se quiser degraus bem definidos: *Max step size* = `0.01`.

---

## 6. Comprovar o item (d) — número de amostras

Período natural `2π/ωn = 1.3695 s`, `T = 0.1369 s` → devem caber **~10 amostras**.

1. Abra o `Scope` ligado na **saída do ZOH(D/A)** (o sinal em degraus).
2. Rode a simulação e dê *Autoscale*.
3. **Conte os degraus horizontais** no intervalo [0 ; 1.37] s → serão ~10.
   - Dica: no Scope, *Measurements → Cursor Measurements*, ponha um cursor em t = 0 e outro em t = 1.3695 s e conte os patamares entre eles.
4. (Opcional, fica didático) Use um `Mux` para mostrar `ω(t)` contínuo **e** a saída do D/A no mesmo Scope, sobrepondo a curva suave aos degraus — a contagem fica óbvia.
5. **Print desse Scope** = figura do item (d).

---

## 7. Prints para o relatório (.tex)

Salvar os dois screenshots **com estes nomes exatos** e subir no Overleaf (o `Trabalho_completo.tex` já tem os `\includegraphics` esperando por eles):

- **`simulink_modelo.png`** → print do diagrama completo (item c)
- **`simulink_amostras.png`** → print do Scope com a contagem dos degraus (item d)

---

## 8. Usando o mesmo modelo na Questão 3

Trocar o bloco `D(z)=1` por cada controlador (`Discrete Transfer Fcn`, *Sample time* = `0.1369`),
rodar o degrau e anotar Tr/Ts/Tp/Mp (devem bater com a Tabela 2 do `.tex`):

| Controlador | Numerator | Denominator |
|---|---|---|
| (a) Lugar das raízes | `[34.2409 -26.7353]` | `[1 -1]` |
| (b) Transformada w   | `[69.8477 -100.0074 35.6626]` | `[1 -1.3481 0.3481]` |
| (c) PID              | `[95.476 -123.800 40.175]` | `[1 -1 0]` |
| (d) Espaço de estados | *não é função de transferência* (observador + ganhos) | — |

- O controlador **(d)** não cabe num `Discrete Transfer Fcn`. Os valores dele já estão validados
  no script `Trabalho_Q3_apoio.m` (use os de lá, ou implemente o observador com um bloco
  `Discrete State-Space` se quiser montar no Simulink).
- **Perturbação de carga (Q3b):** no bloco `Step` do `Td`, ponha *Final value* = `1` e
  *Step time* = `4` (com a malha já em regime). Observe a queda e a recuperação de ω.

> **Atalho:** o script `Trabalho_Q3_apoio.m` já reproduz exatamente esta simulação híbrida
> (D(z) × G(s)) para os 4 controladores e gera os gráficos `resp_degrau_q3.png` e
> `resp_perturbacao.png` automaticamente. O Simulink serve para o print do modelo e a
> comprovação visual.

---

## Observações importantes

- **Por que montar a planta com blocos físicos** (e não uma única `Transfer Fcn` G(s) = 1/(s²+12s+20.05)):
  assim a perturbação `Td` entra no ponto certo (entre Tm e a mecânica), o que será **necessário na Questão 3**.
  Montando como bloco único, teria que refazer depois.
- Conferência rápida (se quiser): rodar o script `Trabalho_Q1_apoio.m` no MATLAB reproduz G(s), H(s),
  o T e o G(z), além de um gráfico que também comprova as ~10 amostras.
- **Ponto a confirmar com a professora:** o enunciado pede "10 amostras por ciclo da resposta ao degrau",
  mas com os parâmetros deste grupo a malha é **superamortecida** (sem oscilação). Por isso usamos `ωn`
  como referência. Vale confirmar se o critério é aceito.
