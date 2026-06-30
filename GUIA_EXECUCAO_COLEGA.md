# Guia de execução — Trabalho de Laboratório de Controle Discreto

**Para:** Luiz E. Passoni de Souza
**O que é:** trabalho em equipe (motor DC) — Questões 1 a 4. **Toda a teoria e os cálculos já
estão prontos** no arquivo `Trabalho_completo.tex` (4 questões resolvidas à mão, controladores
projetados e validados). **Falta apenas a parte de execução**, que está toda neste guia.

Siga os 4 passos abaixo na ordem. Ao final você terá o PDF pronto para entregar.

---

## Pré-requisitos
- **MATLAB** com **Simulink** e **Control System Toolbox** instalados.
- A pasta do projeto com estes arquivos:
  - `Trabalho_completo.tex` ← o documento (vai pro Overleaf)
  - `Trabalho_Q1_apoio.m`, `Trabalho_Q2_apoio.m`, `Trabalho_Q3_apoio.m`, `Trabalho_Q4_apoio.m`
  - `Simulink_Q1_passo_a_passo.md` ← passo a passo detalhado do Simulink
- Uma conta no **Overleaf** (overleaf.com, grátis) — ou LaTeX instalado localmente.

---

## PASSO 1 — Rodar os scripts MATLAB (gera 5 das 7 figuras, automaticamente)

1. Abra o MATLAB e **navegue até a pasta do projeto** (comando `cd 'caminho/da/pasta'` ou pela
   barra de endereço). **Isso é importante:** as figuras são salvas na pasta atual.
2. Rode os scripts (digitando o nome de cada um no Console e Enter, ou abrindo e dando *Run*):

   | Script | O que faz | Figuras que salva (PNG) |
   |---|---|---|
   | `Trabalho_Q1_apoio.m` | Confere Q1 (G(s), H(s), T, G(z)) | (nenhuma — só confirmação) |
   | `Trabalho_Q2_apoio.m` | Projeta os 4 controladores | `rlocus_a.png`, `bode_w.png` |
   | `Trabalho_Q3_apoio.m` | Simula D(z)×G(s) e a perturbação | `resp_degrau_q3.png`, `resp_perturbacao.png` |
   | `Trabalho_Q4_apoio.m` | Controle de posição | `resp_posicao.png` |

3. Confira no Console que aparecem as métricas (Mp, Ts etc.) sem erro. As 5 figuras `.png`
   aparecem **na pasta** automaticamente.
   - Se algum script der **erro vermelho**, copie a mensagem e mande pro Victor.

---

## PASSO 2 — Montar o Simulink (gera as 2 figuras restantes)

1. Siga o arquivo **`Simulink_Q1_passo_a_passo.md`** — tem o diagrama, todos os blocos, parâmetros
   e ligações, passo a passo. Use **T = 0,1369 s** nos ZOH e no D(z).
2. Tire os 2 prints e salve **com estes nomes exatos**:
   - **`simulink_modelo.png`** → print do diagrama completo (Questão 1c)
   - **`simulink_amostras.png`** → print do Scope da saída do D/A, mostrando ~10 degraus por ciclo
     (Questão 1d)
3. (Opcional, reforça a nota) A **seção 8** desse mesmo guia mostra como usar o modelo na
   Questão 3 (trocar os controladores e injetar a perturbação `Td`). Os valores já estão no
   `.tex`; isso serve só para confirmar visualmente.

---

## PASSO 3 — Compilar no Overleaf

1. Em overleaf.com: **New Project → Blank Project**.
2. Abra o `main.tex`, **apague todo o conteúdo** e **cole o conteúdo INTEIRO** do arquivo
   `Trabalho_completo.tex` (da primeira linha `\documentclass...` até `\end{document}`).
3. **Suba as 7 imagens** (botão *Upload*), com os nomes **exatamente** assim:
   `simulink_modelo.png`, `simulink_amostras.png`, `rlocus_a.png`, `bode_w.png`,
   `resp_degrau_q3.png`, `resp_perturbacao.png`, `resp_posicao.png`.
4. Clique em **Recompile**. Baixe o PDF (**Download PDF**).
   - Se faltar alguma imagem, o LaTeX dá erro só naquela figura — basta subir a que falta.
   - Se der outro erro de compilação, copie o log e mande pro Victor.

---

## As 7 imagens (de onde vem cada uma)

| Imagem | Origem |
|---|---|
| `simulink_modelo.png` | Simulink (Passo 2) |
| `simulink_amostras.png` | Simulink (Passo 2) |
| `rlocus_a.png` | `Trabalho_Q2_apoio.m` |
| `bode_w.png` | `Trabalho_Q2_apoio.m` |
| `resp_degrau_q3.png` | `Trabalho_Q3_apoio.m` |
| `resp_perturbacao.png` | `Trabalho_Q3_apoio.m` |
| `resp_posicao.png` | `Trabalho_Q4_apoio.m` |

---

## Checklist final
- [ ] 5 figuras geradas pelos scripts (estão na pasta)
- [ ] 2 prints do Simulink salvos com os nomes certos
- [ ] As 7 imagens subidas no Overleaf
- [ ] `Trabalho_completo.tex` colado como `main.tex`
- [ ] Documento **compila sem erro** e mostra as figuras
- [ ] PDF baixado com as 4 questões

---

## Observações (pontos que podem render pergunta da professora)
- **Q1(b):** o sistema deste grupo é **superamortecido** (sem "ciclo" de oscilação); adotamos a
  frequência natural ωn como referência para as "10 amostras por ciclo". É a interpretação padrão,
  mas se puder, **confirme o critério com a professora**.
- **Q2(b) (transformada w):** o zero do PI cancela o polo lento da planta — é o que faz o projeto
  atender Ts < 2 s (sem isso, o método não fecha por causa do zero de fase não-mínima da amostragem).
- Tudo foi conferido numericamente; os 4 controladores atendem Mp ≤ 5%, Ts < 2 s e erro ≤ 1%.
