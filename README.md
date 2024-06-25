In this project, a set of observations are considered on some white wine varieties involving their chemical properties and ranking by tasters. The wine industry has shown a recent growth spurt as social drinking is on the rise. The price of wine depends on a rather abstract concept of wine appreciation by wine tasters. Pricing of wine depends on such a volatile factor to some extent. Another key factor in wine certification and quality assessment is physicochemical tests which are laboratory-based and take into account factors like acidity, pH level, presence of sugar, and other chemical properties. For the wine market, it would be of interest if the human quality of testing could be related to the chemical properties of wine so that the certification and quality assessment and assurance process is more controlled. 

The dataset includes samples of white wine (whitewine_v6.xls) has 2700 varieties. All wines are produced in a particular area of Portugal. Data are collected on 12 different properties of the wines, one of which is Quality (i.e. the last column), based on sensory data, and the rest are on chemical properties of the wines including density, acidity, alcohol content, etc. All chemical properties of wines are continuous variables. Quality is an ordinal variable with a possible ranking from 1 (worst) to 10 (best). Each variety of wine is tasted by three independent tasters and the final rank assigned is the median rank given by the tasters. For this clustering part, only the first 11 attributes are considered for calculations. Clustering is an unsupervised scheme, thus, the information included in the “quality” attribute can’t be used. 

Description of attributes:
1.	fixed acidity: most acids involved with wine or fixed or non-volatile (do not evaporate readily)
2.	volatile acidity: the amount of acetic acid in wine, which at too high of levels can lead to an unpleasant, vinegar taste
3.	citric acid: found in small quantities, citric acid can add ‘freshness’ and flavor to wines
4.	residual sugar: the amount of sugar remaining after fermentation stops, it’s rare to find wines with less than 1 gram/liter and wines with greater than 45 grams/liter are considered sweet
5.	chlorides: the amount of salt in the wine
6.	free sulfur dioxide: the free form of SO2 exists in equilibrium between molecular SO2 (as a dissolved gas) and bisulfite ion; it prevents microbial growth and the oxidation of wine
7.	total sulfur dioxide: the amount of free and bound forms of S02; in low concentrations, SO2 is mostly undetectable in wine, but at free SO2 concentrations over 50 ppm, SO2 becomes evident in the nose and taste of wine
8.	density: the density of water is close to that of water depending on the percent alcohol and sugar content
9.	pH: describes how acidic or basic wine is on a scale from 0 (very acidic) to 14 (very basic); most wines are between 3-4 on the pH scale
10.	sulfates: a wine additive that can contribute to sulfur dioxide gas (S02) levels, which acts as an antimicrobial and antioxidant
11.	alcohol: the percent alcohol content of the wine
12.	Output variable (based on sensory data): quality (score between 0 and 10)

The work is divided into two parts: 
1: In the first part, an analysis is performed on the wine dataset with all initial attributes (i.e. the first 11 features), as the aim is to assess clustering results using all input variables.
2: In the second part, principal component analysis (PCA) is applied to reduce the input dimensionality and the newly produced dataset will be again clustered. This part aims to understand the principles and effects of reducing dimensionality in multi-dimensional problems. 
