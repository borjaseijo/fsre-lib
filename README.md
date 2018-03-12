# Feature Selection Ranker Ensemble library
Obtain relevant subsets of features using ensemble approaches. Return different subsets of relevant features in a dataset according to different feature selection methods, union methods and thresholding methods. Both individual and ensemble results are returned.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

You need at least the following software versions:
- Windows 8
- Matlab 2015a.

### Installing and testing

1. Open the location of library into Matlab explorer
2. Load *Yeast* dataset from folder data_test (double click in the *yeast* dataset file).
3. Call the function from command window:
```
[F,I,F_README,I_README,Fisher,Overlap,Efficiency] = ...
       fs_ensemble_ranking(true, dataset, classes, ...
                           [1,2,3,4,5,6], [1,2,3,4,5,6,7], ...
                           [1,2,3,4,5,6,7,8,9,10,11,12,13]);
```

*fs_ensemble_ranking* is the main function of the library. See more details on how to use inside the source file.

## Built With

* [Matlab](https://es.mathworks.com/products/matlab.html)
* [Weka](https://www.cs.waikato.ac.nz/ml/weka/)

## Authors

* [**Borja Seijo-Pardo**](https://scholar.google.es/citations?user=A8-eWegAAAAJ)
* [**Verónica Bolón-Canedo**](https://scholar.google.es/citations?user=ameK2ocAAAAJ&hl=es)
* [**Amparo Alonso-Betanzos**](https://scholar.google.es/citations?user=4SX-5-oAAAAJ&hl=es)

Laboratory for Research and Development in Artificial Intelligence (LIDIA Group) Universidad of A Coruna

## License

This project is licensed under the MIT License.

## Acknowledgments

This research has been financially supported in part by the *Ministerio Español de Economía y Competitividad* (research project TIN 2015-65069-C2-1-R), by the *Xunta de Galicia* (research projects GRC2014/035 and the *Centro Singular de Investigación de Galicia*, accreditation 2016-2019) and by the *European Union* (FEDER/ERDF).