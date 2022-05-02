



# Preparação / Instalação

1. Download [WEKA](https://waikato.github.io/weka-wiki/downloading_weka/) para distribuição adequada.

2. Instale o wekaPython.
    - GUI
        - Tools -> Package Manager
            - Busque por ```wekaPython``` -> instale o package (não confundir com WekaPyScript).
            - Busque por ```netlib``` -> instale o package adequado ao seu sistema.
    - Command line
        - ```./weka.sh -main weka.core.WekaPackageManager -install-package netlibNativeLinux``` (ou outro caso seja outro SO lista [aqui](https://weka.sourceforge.io/packageMetaData/))
        - ```./weka.sh -main weka.core.WekaPackageManager -install-package wekaPython```
3. Instalação de packages adicionais:
    - ```pip install numpy pandas matplotlib scikit-learn xgboost```

4. Instale BLAS/LAPACK.
    - Linux
        - ```sudo apt-get install libblas-dev liblapack-dev```
        - ```sudo ln -s /usr/lib/x86_64-linux-gnu/libblas.so.3 /usr/lib/libblas.so.3```
        - ```sudo ln -s /usr/lib/x86_64-linux-gnu/liblapack.so.3 /usr/lib/liblapack.so.3```
    - Windows
        - Siga o [guia](https://icl.cs.utk.edu/lapack-for-windows/lapack/). 
        - Obs: não testei para ver se esse guia é fácil de seguir.


- OPCIONAL: se quiser utilizar GPU:

    5. instale [CUDA](https://developer.nvidia.com/cuda-downloads).
        - O link leva para um "menu" que você irá marcar as opções do seu sistema e escolher um método de instalação.
        - Ao final você terá instruções de como instalar.

    6. Copie o [*template*](https://docs.nvidia.com/cuda/nvblas/#configuration_example) do arquivo ```nvblas.conf``` para o diretório local sendo utilizado.

    7. Edite o arquivo ```nvblas.conf``` para que contenha:

        - ```NVBLAS_CPU_BLAS_LIB=/usr/lib/x86_64-linux-gnu/blas/libblas.so.3```

    8. Crie variável de ambiente ```LD_LIBRARY_PATH```:

        - ```export LD_LIBRARY_PATH=/usr/local/cuda-11.6/lib64:/usr/lib/x86_64-linux-gnu/blas/libblas.so.3```

    9. Adicione ```LD_PRELOAD=libnvblas.so``` no início de todos os comandos ```./weka.sh args```


# Datasets

Datasets sugeridos para realização do profiling. Divididor em duas categorias:

## Reais (e "mock-up real")
- [HIGGS](https://archive.ics.uci.edu/ml/datasets/HIGGS): problema de classificação para detectar sinais que caracterizam bosons de Higgs. Possui 11m instâncias, 28 atributos (reais).
    - Considerem utilizar apenas as primeiras 1m instâncias.
    - Necessário pré-processamento, ver **Preparação / Instalação**.
- [Covertype](https://github.com/hmgomes/AdaptiveRandomForest/raw/master/COVT.arff.zip): dataset clássico para benchmarks. Problema de classificação multiclasse desbalanceado, 7 classes com diferentes proporções de instâncias. Representa imagens de 30m x 30m de florestas dos EUA. Cada classe corresponde a um tipo diferente. Contém 581k instâncias e 54 atributos.
- [GMSC](https://github.com/hmgomes/AdaptiveRandomForest/raw/master/GMSC.arff.zip): problema de classificação para decidir se aprova ou não um empréstimo baseado em dados históricos de clientes que efetuaram empréstimos. Contém 150k instâncias e 10 atributos numéricos.

## Sintéticos
- [RandomRBF](https://weka.sourceforge.io/doc.dev/weka/datagenerators/classifiers/classification/RandomRBF.html): gerador de dados numéricos que cria centros para cada classe. Os dados são gerados através de *offsets* destes centros utilizando equações Gaussianas. O link leva para o Javadoc desta classe.
    - Comando/script para gerar: ```create-RBF.sh```
    - Utilize opção -h para saber os argumentos possíveis.


- [RDG1](https://weka.sourceforge.io/doc.dev/weka/datagenerators/classifiers/classification/RDG1.html): gerador de dados que utiliza uma lista de regras de decisão. Instâncias geradas uma a uma, através de regras de decisão que são adicionadas a uma lista. O link leva para o Javadoc desta classe.
    - Comando/script para gerar: ```create-RDG.sh```
    - Utilize opção -h para saber os argumentos possíveis.



# Sugestões de algoritmos para fazer o profiling

Em todos exemplos de linha de comando, as ```$variaveis_de_ambiente``` devem ser setadas pelo usuário.

O parâmetro ```n_jobs``` funciona para qualquer algoritmo do ```scikit-learn```.

Ajuste o valor da opção ```-memory``` para o seu hardware.

Nos comandos a seguir, a saída do algoritmo está sendo direcionada para um arquivo que possui as configurações do experimento identificadas pelo nome para que a análise pudesse ser feita mais tarde. As linhas de comando foram tiradas de um *script* utilizado "internamente" para coletar informações de *speedup* e outras métricas. 

No caso do *profile*, provavelmente será necessário um controle mais rígido na hora de iniciar os experimentos. Fiquem à vontade para modificar.

1. [XGBoost](https://xgboost.readthedocs.io/en/stable/)
    <!-- - Exemplos de comando para excução: -->
    - Sequencial com CV: ```./weka.sh -memory 32g -main weka.Run weka.classifiers.sklearn.ScikitLearnClassifier -learner XGBClassifier -parameters "tree_method=\"hist\",n_jobs=1" -t $dataset -py-command python > $RESULT_DIR/XGB-$dataset-cpu-CV-1job```
    - Paralelo com 4 *threads e *split* 80/20 : ```./weka.sh -memory 32g -main weka.Run weka.classifiers.sklearn.ScikitLearnClassifier -split-percentage 80 -v -learner XGBClassifier -parameters "tree_method=\"hist\",n_jobs=4" -t $dataset -py-command python > $RESULT_DIR/XGB-$dataset-cpu-CV-4jobs```
    - Utilizando GPU com *split* 80/20:  ```./weka.sh -memory 32g -main weka.Run weka.classifiers.sklearn.ScikitLearnClassifier -split-percentage 80 -v -learner XGBClassifier -parameters "tree_method=\"gpu_hist\"" -t $dataset -py-command python > $RESULT_DIR/XGB-$dataset-gpu-CV```
2. [RandomForest](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.RandomForestClassifier.html)
    - Paralelo com 8 *threads* e *split* 80/20. Profundidade máxima das árvores=16. ```./weka.sh -memory 32g -main weka.Run weka.classifiers.sklearn.ScikitLearnClassifier -split-percentage 80 -v -learner RandomForestClassifier -dont-fetch-model -parameters "max_depth=16,max_samples=1.0,n_jobs=8" -t $dataset -py-command python > $RESULT_DIR/RFC-$dataset-cpu-skl-noCV-8jobs```

3. [LinearRegression](https://scikit-learn.org/stable/modules/generated/sklearn.linear_model.LinearRegression.html?highlight=linear%20regression#sklearn.linear_model.LinearRegression):
    - Sequencial com *split* 80/20```./weka.sh -memory 32g -main weka.Run weka.classifiers.sklearn.ScikitLearnClassifier -split-percentage 80 -v -dont-fetch-model -learner LinearRegression -t $dataset -py-command python > $RESULT_DIR/LR-$dataset-cpu-skl-noCV```



# *Lifehacks*
- Utilizar apenas as primeiras X linhas do dataset HIGGS
    - ```head -X HIGGS.csv > HIGGS_Xsamples.csv```, onde X é um inteiro.
- Converter CSV para ARFF
    - ```java -cp weka.jar weka.core.converters.CSVLoader nome.csv > nome.arff```
- Converter ARFF para CSV
    - ```./weka.sh -main weka.Run .CSVSaver -i nome.arff -o nome.csv```
