
# Project Report

__Objective__:
- Apply Machine Learning Algorithms to predict the result of FIFA World Cup 2018.



__Data__: The Data was assembled from multiple sources, some of the from Kaggle, others come from FIFA website, and individual team information has been manually imputed.



__Feature Selection__: This World Cup has been unique for so many reasons. There have been numerous upsets and plenty of records broken. Keeping that uniqueness in mind , I have decided to use only data avaialble from the World Cup Group stages to make a prediction. Sounds incredibly challenging doesn't it? Let's see how it turns out. I have selected the following factors as most important,

1. Average Goals Scored in the Group stages
2. Average Goals Conceded in the Group stages
3. Goal Difference at the end of the Group Stages
4. Total Wins in the Group Stage
5. Total Losses in the Group Stage
6. Average Odds 
7. Pressure on the Team to win the World Cup



__Team mate__: Joji John Thomas


# Process

![Process followed](https://github.com/Lijo-Thomas/FIFA-World-Cup-Challenge-2018/blob/master/Images/Process.png)


# Data
### Data Sources
The data was taken from the following sources,
1. [FIFA World Cup 2018](https://www.kaggle.com/ahmedelnaggar/fifa-worldcup-2018-dataset/data)
2. [International match results 1872 - 2018](https://www.kaggle.com/martj42/international-football-results-from-1872-to-2017/data)
3. [Betting Odds ](http://www.oddsportal.com)
4. [World Cup Qualifiers Results and Table](www.worldfootball.net)


### Features 


|Team         | Avg.GS| Avg.GC| Goal.Difference| Wins| Losses| Avg.Odds| Pressure|
|:------------|------:|------:|---------------:|----:|------:|--------:|--------:|
|Uruguay      |   1.67|   0.00|               5|    3|      0|     1.84|      5.0|
|Russia       |   2.67|   1.33|               4|    2|      1|     2.11|      7.5|
|Saudi Arabia |   0.67|   2.33|              -5|    1|      2|    10.84|      0.0|
|Egypt        |   0.67|   2.00|              -4|    0|      3|     4.84|      5.0|
|Spain        |   2.00|   1.67|               1|    1|      0|     1.54|     10.0|
|Portugal     |   1.67|   1.33|               1|    1|      0|     2.56|     10.0|
|Iran         |   0.67|   0.67|               0|    1|      1|     9.96|      0.0|
|Morocco      |   0.67|   1.33|              -2|    0|      2|     6.18|      0.0|
|France       |   1.00|   0.33|               2|    2|      0|     1.65|     10.0|
|Denmark      |   0.67|   0.33|               1|    1|      0|     3.19|      5.0|
|Peru         |   0.67|   0.67|               0|    1|      2|     4.27|      0.0|
|Australia    |   0.67|   1.67|              -3|    0|      2|     6.02|      0.0|
|Croatia      |   2.33|   0.33|               6|    3|      0|     2.54|      5.0|
|Argentina    |   1.00|   1.67|              -2|    1|      1|     1.64|     10.0|
|Nigeria      |   1.00|   1.33|              -1|    1|      2|     5.04|      5.0|
|Iceland      |   0.67|   1.67|              -3|    0|      2|     6.16|      0.0|
|Brazil       |   1.67|   0.33|               4|    2|      0|     1.39|     10.0|
|Switzerland  |   1.67|   1.33|               1|    1|      0|     4.22|      5.0|
|Serbia       |   0.67|   1.33|              -2|    1|      2|     4.07|      5.0|
|Costa Rica   |   0.67|   1.67|              -3|    0|      2|    10.72|      0.0|
|Sweden       |   1.67|   0.67|               3|    2|      1|     4.50|      0.0|
|Mexico       |   1.00|   1.33|              -1|    2|      1|     3.72|      5.0|
|South Korea  |   1.00|   1.00|               0|    1|      2|     9.68|      0.0|
|Germany      |   0.67|   1.33|              -2|    1|      2|     1.38|     10.0|
|Belgium      |   3.00|   0.67|               7|    3|      0|     2.09|      7.5|
|England      |   2.67|   1.00|               5|    2|      1|     1.73|      7.5|
|Tunisia      |   1.67|   2.67|              -3|    1|      2|     7.49|      0.0|
|Panama       |   0.67|   3.67|              -9|    0|      3|    13.57|      0.0|
|Colombia     |   1.67|   0.67|               3|    2|      1|     1.95|      7.5|
|Japan        |   1.33|   1.33|               0|    1|      1|     3.76|      0.0|
|Senegal      |   1.33|   1.33|               0|    1|      1|     3.72|      5.0|
|Poland       |   0.67|   1.67|              -3|    1|      2|     2.91|      5.0|



# Exploratory Data Analysis
This helps us understand the data better

__1. Let's see who the favourites were according to the bookmaker odds in the group stages,__

![Odds](https://github.com/Lijo-Thomas/FIFA-World-Cup-Challenge-2018/blob/master/Images/Bookmaker%20ODDS.png)

_Germany_ , _Brazil_ and _Spain_ were considered the hot favourites to win despite their initial hiccups.


__2. The most dominant teams in the group stages were,__

![Dominant Teams](https://github.com/Lijo-Thomas/FIFA-World-Cup-Challenge-2018/blob/master/Images/Goal%20Diff.png)


__3. The most devastating teams were,__

![Devastating Teams](https://github.com/Lijo-Thomas/FIFA-World-Cup-Challenge-2018/blob/master/Images/Goals%20Scored.png)


__4. Only three teams manged to keep a 100% win record. They were,__

![Wins](https://github.com/Lijo-Thomas/FIFA-World-Cup-Challenge-2018/blob/master/Images/Wins.png)



# Model Training and Evaluation
### Train-Test ratio
We split data into 70:30
### Model
1. Logistic Regression
2. SVM
3. Random Random Forest





# Prediction

Based on our Model, these were our final predictions,

![predictions](https://github.com/Lijo-Thomas/FIFA-World-Cup-Challenge-2018/blob/master/Images/Bracket.png)



Our Semi Final predictions were,

_Uruguay vs Brazil_    ---> __Uruguay__ wins

_Spain vs England_     ---> __Spain__ wins


We predict the winner of the FINAL to be __Uruguay__
