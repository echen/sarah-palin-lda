// From the Stanford Topic Modeling Toolbox: http://nlp.stanford.edu/software/tmt/tmt-0.3/.
// java -Xmx1024m -jar tmt-0.3.3.jar -Dscalanlp.distributed.hub=socket://42-149-58-18.rev.home.ne.jp:53686/hub -Dscalanlp.distributed.id=/tmt/8 edu.stanford.nlp.tmt.TMTMain "2-training.scala"

import scalanlp.io._;
import scalanlp.stage._;
import scalanlp.stage.text._;
import scalanlp.text.tokenize._;
import scalanlp.pipes.Pipes.global._;

import edu.stanford.nlp.tmt.stage._;
import edu.stanford.nlp.tmt.model.SymmetricDirichletParams;
import edu.stanford.nlp.tmt.model.lda._;
import edu.stanford.nlp.tmt.model.llda._;

// The source file is a CSV with 
// * id of the email in the first column
// * text of the email in the second column.
val source = CSVFile("emails.csv") ~> IDColumn(1);

val tokenizer = {
  SimpleEnglishTokenizer() ~>            // tokenize on space and punctuation
  CaseFolder() ~>                        // lowercase everything
  WordsAndNumbersOnlyFilter() ~>         // ignore non-words and non-numbers
  MinimumLengthFilter(3)                 // take terms with >= 3 characters
}

val text = {
  source ~>                              	// read from the source file
  Column(2) ~>                           	// select column containing text
  TokenizeWith(tokenizer) ~>             	// tokenize with tokenizer above
  TermCounter() ~>                       	// collect counts (needed below)
  TermMinimumDocumentCountFilter(10) ~>  	// filter terms in < 30 docs
  TermDynamicStopListFilter(30) ~>       	// filter out 30 most common terms
  DocumentMinimumLengthFilter(10)         // take only docs with >= 10 terms
}

// Turn the text into a dataset ready to be used with LDA.
val dataset = LDADataset(text);

// Define the model parameters.
val params = LDAModelParams(numTopics = 30, dataset = dataset,
  topicSmoothing = SymmetricDirichletParams(0.01),
  termSmoothing = SymmetricDirichletParams(0.01)
);

// Name of the output model folder to generate.
val modelPath = file("lda-" + dataset.signature + "-" + params.signature);

// Trains the model: the model (and intermediate models) are written to the
// output folder. If a partially trained model with the same dataset and
// parameters exists in that folder, training will be resumed.
TrainCVB0LDA(params, dataset, output = modelPath, maxIterations = 10);