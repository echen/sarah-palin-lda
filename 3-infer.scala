// From the Stanford Topic Modeling Toolbox: http://nlp.stanford.edu/software/tmt/tmt-0.3/.
// java -Xmx1024m -jar tmt-0.3.3.jar -Dscalanlp.distributed.hub=socket://42-149-58-18.rev.home.ne.jp:53686/hub -Dscalanlp.distributed.id=/tmt/8 edu.stanford.nlp.tmt.TMTMain "3-infer.scala"

import scalanlp.io._;
import scalanlp.stage._;
import scalanlp.stage.text._;
import scalanlp.text.tokenize._;
import scalanlp.pipes.Pipes.global._;

import edu.stanford.nlp.tmt.stage._;
import edu.stanford.nlp.tmt.model.lda._;
import edu.stanford.nlp.tmt.model.llda._;

// The path of the model to load.
val modelPath = file("lda-86a58316-30-2b1a90a6");
val model = LoadCVB0LDA(modelPath);

// A new dataset for inference.
val source = CSVFile("emails.csv") ~> IDColumn(1);

val text = {
  source ~>                              // read from the source file
  Column(2) ~>                           // select column containing text
  TokenizeWith(model.tokenizer.get)      // tokenize with existing model's tokenizer
}

// Base name of the output files to generate.
val output = file(modelPath, source.meta[java.io.File].getName.replaceAll(".csv",""));

// turn the text into a dataset ready to be used with LDA
val dataset = LDADataset(text, termIndex = model.termIndex);

println("Writing document distributions to " + output + "-document-topic-distributions.csv");
val perDocTopicDistributions = InferCVB0DocumentTopicDistributions(model, dataset);
CSVFile(output+"-document-topic-distributuions.csv").write(perDocTopicDistributions);

println("Writing topic usage to "+output+"-usage.csv");
val usage = QueryTopicUsage(model, dataset, perDocTopicDistributions);
CSVFile(output+"-usage.csv").write(usage);

println("Estimating per-doc per-word topic distributions");
val perDocWordTopicDistributions = EstimatePerWordTopicDistributions(model, dataset, perDocTopicDistributions);

println("Writing top terms to "+output+"-top-terms.csv");
val topTerms = QueryTopTerms(model, dataset, perDocWordTopicDistributions, numTopTerms=100);
CSVFile(output+"-top-terms.csv").write(topTerms);