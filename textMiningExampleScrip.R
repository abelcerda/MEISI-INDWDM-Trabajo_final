# Install all the packages if not.
# install.packages("tm")  # for text mining
# install.packages("SnowballC") # for text stemming
# install.packages("wordcloud") # word-cloud generator 
# install.packages("RColorBrewer") # color palettes
# install.packages("syuzhet") # for sentiment analysis
# install.packages("ggplot2") # for plotting graphs
# install.packages("redux")

library("tm")
library("SnowballC")
library("wordcloud")
library("RColorBrewer")
library("syuzhet")
library("ggplot2")
library("redux")

# Iniciar la conexión con el servidor Redis: 
r = redux::hiredis()
# Los datos del archivo CSV están cargado en la llave kindle_review. Para acceder 
# a ellos se usa el método GET y se los puede guardar en una variable (por ejemplo csv):
csv = r$GET("kindle_review") 
# Con el paso anterior, la variable csv tendrá almacenado todo el contenido del archivo CSV
# como una enorme cadena de texto. Este texto debe ser transformado en tabla para su utilización. Esta transformación se realiza con el siguiente comando:
data <- read.csv(text=csv,sep=',') 
# creando el corpus de texto
TextDoc  <- Corpus(VectorSource(data$review))
length(data)
colnames(data)
# reemplazando "/", "@" and "|" con espacios
toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
TextDoc <- tm_map(TextDoc, toSpace, "/")
TextDoc <- tm_map(TextDoc, toSpace, "@")
TextDoc <- tm_map(TextDoc, toSpace, "\\|")
# Convertir el texto de los docuementos del corpus a minisculas
TextDoc <- tm_map(TextDoc, content_transformer(tolower))
# Remover numeros
TextDoc <- tm_map(TextDoc, removeNumbers)
# Remover las stopwords (en ingles) del texto
TextDoc <- tm_map(TextDoc, removeWords, stopwords("english"))
# Remover las stopword propias, se especifican como un vector
TextDoc <- tm_map(TextDoc, removeWords, c("s", "company", "team"))
# Remover puntuaciones
TextDoc <- tm_map(TextDoc, removePunctuation)
# Remover espacios en blanco adicionales en los documentos del corpus
TextDoc <- tm_map(TextDoc, stripWhitespace)
# Proceso de stemming sobre el corpus, se reduce las palabras a su raíz o base común.
TextDoc <- tm_map(TextDoc, stemDocument)
# Se construye una matriz término-documento utilizando la función TermDocumentMatrix() 
# del paquete tm. La matriz término-documento es una representación matricial de los términos 
# (palabras) en los documentos del corpus.
TextDoc_dtm <- TermDocumentMatrix(TextDoc)
# Se convierte la matriz término-documento TextDoc_dtm en una matriz regular utilizando 
# la función as.matrix(). Esto permite trabajar con la matriz de término-documento 
# como una matriz regular en R.
dtm_m <- as.matrix(TextDoc_dtm)
# Se calcula la suma de las frecuencias de términos por fila de la matriz término-documento (dtm_m) 
# utilizando rowSums(). Luego, se ordenan los resultados en orden descendente utilizando 
# la función sort(). Esto da como resultado un vector (dtm_v) que contiene
# las sumas de frecuencias de términos ordenadas de manera descendente.
dtm_v <- sort(rowSums(dtm_m),decreasing=TRUE)
# Se crea un nuevo marco de datos (dtm_d) con dos columnas: "word" (palabra) y "freq" (frecuencia). 
# La columna "word" contiene los nombres de los términos y la columna "freq" contiene 
# las frecuencias de cada término.
dtm_d <- data.frame(word = names(dtm_v),freq=dtm_v)
# Mostrar las 5 palabras mas frecuentes
head(dtm_d, 5)
barplot(dtm_d[1:10,]$freq, las = 2, names.arg = dtm_d[1:10,]$word,
        col ="lightgreen", main ="Top 15 palabras mas frecuentes",
        ylab = "Frecuencia de Palabras")
# Creando un grafico de torta de las 5 palabras mas frecuentes
x <- c(15696, 11329, 10921,6580,6019)
labels <- c("book", "stori", "read","like","one")
# Graficar torta
pie(x, labels, main = "Grafico de torta para el Top 5 de Palabras más frecuentes", col = rainbow(length(x)))
legend("topright", c("book","stori","read","like","one"), cex = 0.8,fill = rainbow(length(x)))
# Generar una nube de palabras
set.seed(1234)
wordcloud(words = dtm_d$word, freq = dtm_d$freq, min.freq = 5,
          max.words=100, random.order=FALSE, rot.per=0.40, 
          colors=brewer.pal(8, "Dark2"))
# Encontrar Asociaciones entre las palabras: La correlación se basa en la medida de similitud 
# entre los términos en los documentos.
findAssocs(TextDoc_dtm, terms = c("book","stori","read"), corlimit = 0.25)
# En lugar de especificar las palabras se utilizan aquellas 
# que al menos aparezcan 10 veces dentro de la matrix de terminos
findAssocs(TextDoc_dtm, terms = findFreqTerms(TextDoc_dtm, lowfreq = 10), corlimit = 0.25)
# El comando calculará el sentimiento de los textos utilizando el método "syuzhet", que es un enfoque basado en léxico. El paquete "syuzhet" proporciona un conjunto de léxicos predefinidos que asignan puntuaciones de sentimiento a las palabras en los textos. Estas puntuaciones se utilizan para calcular un puntaje de sentimiento general para cada texto.
# El resultado del comando será un vector llamado "syuzhet_vector" que contiene los puntajes de sentimiento calculados para cada texto en la columna "reviewText". Cada valor en el vector representa el sentimiento asociado con el texto correspondiente.
# Es importante tener en cuenta que el cálculo del sentimiento es una tarea subjetiva y depende del léxico utilizado y del enfoque de análisis. El método "syuzhet" en particular se basa en un enfoque léxico y puede tener sus propias limitaciones y sesgos.
syuzhet_vector <- get_sentiment(data$reviewText, method="syuzhet")
head(syuzhet_vector)
summary(syuzhet_vector)
# El método "bing" se refiere a un léxico específico llamado "Bing Liu's Opinion Lexicon". Este léxico contiene palabras clasificadas previamente con puntuaciones de sentimiento, donde las palabras se consideran positivas o negativas según su uso común en textos. La función get_sentiment() utiliza este léxico para asignar puntuaciones de sentimiento a las palabras en los textos y calcular un puntaje de sentimiento general para cada texto.
# La diferencia clave entre el método "bing" y el método "syuzhet" es el léxico utilizado. Mientras que "syuzhet" utiliza un léxico más general y versátil, "bing" se basa en un léxico específico desarrollado por Bing Liu para análisis de opiniones. La elección del método dependerá de las necesidades específicas del análisis de sentimientos y del contexto en el que se aplique.
# El resultado del código será un vector llamado "bing_vector" que contiene los puntajes de sentimiento calculados para cada texto en la columna "reviewText", utilizando el léxico "Bing Liu's Opinion Lexicon".
# Es importante tener en cuenta que el enfoque basado en léxicos como "bing" tiene sus limitaciones y puede no capturar completamente el contexto y las sutilezas del sentimiento en los textos. Es recomendable evaluar los resultados y considerar otras técnicas de análisis de sentimientos si se requiere una mayor precisión o contextualización.
bing_vector <- get_sentiment(data$reviewText, method="bing")
head(bing_vector)
summary(bing_vector)
# El método "afinn" se refiere a un léxico específico llamado "AFINN-111" que 
# fue creado por Finn Årup Nielsen. Este léxico contiene un conjunto de palabras 
# con puntuaciones de sentimiento preasignadas. Cada palabra en el léxico tiene un valor
# numérico que indica su polaridad de sentimiento, donde los valores positivos 
# indican sentimiento positivo y los valores negativos indican sentimiento negativo.
afinn_vector <- get_sentiment(data$reviewText, method="afinn")
head(afinn_vector)
summary(afinn_vector)

# head(syuzhet_vector): Selecciona las primeras observaciones del vector syuzhet_vector. head() es una función que devuelve las primeras filas de un objeto, por defecto las primeras 6 filas. En este caso, se están seleccionando las primeras observaciones del vector syuzhet_vector.
# sign(): Es una función que devuelve el signo de cada elemento de un vector. Los valores negativos se representan como -1, los valores positivos como 1 y los valores cero como 0.
# rbind(): Es una función que combina vectores, matrices o data frames por filas. En este caso, se utiliza para combinar verticalmente los resultados de las tres llamadas a sign().
# El resultado del comando será una matriz donde cada fila representa las primeras observaciones de los vectores syuzhet_vector, bing_vector y afinn_vector con sus respectivos signos (-1, 0 o 1). Cada columna de la matriz corresponderá a uno de los vectores.
# La función sign() se utiliza en este caso para obtener una representación simplificada del sentimiento en cada vector, donde se considera si el sentimiento es negativo, positivo o neutral (0). La combinación vertical de los resultados de sign() proporciona una visión comparativa del signo del sentimiento según los diferentes enfoques o léxicos utilizados (syuzhet, bing y afinn).
rbind(
  sign(head(syuzhet_vector)),
  sign(head(bing_vector)),
  sign(head(afinn_vector))
)
 
# la función get_nrc_sentiment() para calcular el sentimiento de los textos en la
# columna "reviewText" de un objeto de datos llamado "data" utilizando el 
# léxico NRC (National Research Council) Sentiment Lexicon.
d<-get_nrc_sentiment(data$reviewText)
head (d,10)
#Transpuesta
td<-data.frame(t(d)) 
td_new <- data.frame(rowSums(td[2:253])) 
names(td_new)[1] <- "count"
td_new <- cbind("sentiment" = rownames(td_new), td_new)
rownames(td_new) <- NULL
td_new2<-td_new[1:8,] 
quickplot(sentiment, data=td_new2, weight=count, geom="bar", fill=sentiment, ylab="count")+ggtitle("Survey sentiments")


# Crear una matriz término-documento
dtm <- DocumentTermMatrix(corpus) 
# Eliminar términos poco frecuentes o dispersos
dtm_sparse <- removeSparseTerms(dtm, 0.40) 
# Ver los términos resultantes
terms <- colnames(dtm_sparse)
print(terms)

# Realizar agrupamiento jerárquico en dtm_sparse
dist_matrix <- dist(dtm_sparse,method = "euclidean")  # Calcular la matriz de distancias
hc <- hclust(dist_matrix, method = "complete")  # Realizar el agrupamiento jerárquico

# Crear el dendrograma
plot(hc, hang = -1)