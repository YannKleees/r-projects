# R projects

Data analysis and machine learning in R from the course Data Analysis and Machine Learning (MSc Applied Data Science, Utrecht University, 2026). The two reports are group work; each one ends with a list of who did what.

| Project | What it does | Report |
|---|---|---|
| [supervised-learning](supervised-learning) | Predicts students' exam scores from 30 background features. Compares a mean baseline, linear regression, a regression tree, KNN and random forests with 10-fold cross-validation, then tunes the random forest. | [view](https://yannkleees.github.io/r-projects/supervised-learning/report.html) |
| [text-clustering](text-clustering) | Groups 5,000 IMDB movie reviews without labels. TF-IDF and word2vec representations; K-means, K-medians, a Gaussian mixture model and LDA, evaluated with the silhouette and sentiment purity. | [view](https://yannkleees.github.io/r-projects/text-clustering/report.html) |
| [labs](labs) | Course labs: linear regression on the Boston housing data, classification on the Default data. | |

## Run it

Each report is a [Quarto](https://quarto.org) document. Install R and Quarto, install the packages listed at the top of the report, then render it from its folder:

```
quarto render report.qmd
```

The rendered reports are included as `report.html`.

## Data

- supervised-learning: the [Student Performance](https://archive.ics.uci.edu/dataset/320/student+performance) data (Cortez and Silva, 2008, CC BY 4.0), split into training and test sets for the course, with the grade standardised as `score`.
- text-clustering: the `movie_review` data that ships with the text2vec package.
- labs: the `Boston` (MASS) and `Default` (ISLR) data sets.

## License

MIT, see [LICENSE](LICENSE).
