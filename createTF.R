createTF=function(){
  
  set.seed(104)
  library(keras)
  library(tensorflow)
  tf$random$set_seed(104)
  path_name = "Datasets/"
  
  L=alexanderdata(path_name)
  final.training=L$train
  final.test=L$test
  
  X_train = scale(final.training[,1:5]) # attributes scaled:center and scaled:scale
  y_train = to_categorical(final.training$Y)
  
  # get weights
  s=table(y_train[,2])
  ws = rep(0,2)
  ws[1]=(1/s[1])*sum(s)/2
  ws[2]=(1/s[2])*sum(s)/2
  
  X_test=final.test[,1:5]
  n=nrow(X_test)
  C=matrix(rep(attributes(X_train)$'scaled:center',each=n),nrow=n,ncol=5)
  S=matrix(rep(attributes(X_train)$'scaled:scale',each=n),nrow=n,ncol=5)
  X_test=as.matrix((X_test-C)/S)
  y_test <- to_categorical(final.test$Y)
  Xout=matrix(data=0,ncol=7,nrow=441)
  colnames(Xout)=c("learn_rate","weight_val","train_sens","train_spec","test_sens","test_spec","thresh")
  irow = 0
  for ( learn_rate in 10^seq(-4,-2,length.out=21)){
    for (weight_val in seq(0.7,1.4,length.out=21)){
      tf$random$set_seed(104)
      irow = irow + 1
      cat(paste0("# ",irow,":Running, learning rate=",learn_rate," cost weight=",weight_val,"\n"))
      ws_s=ws
      ws_s[2]=weight_val*ws[2]     
      model <- keras_model_sequential()
      # MLP model
      model %>% 
        layer_dense(units = 15, activation = 'relu', input_shape = 5) %>% 
        layer_dropout(rate = 0.5) %>% 
        layer_dense(units = 2, activation = 'softmax') #softmax sigmoid
      
      history <-model %>% compile(
        loss = 'binary_crossentropy',
        optimizer =optimizer_adam(lr=learn_rate),
        metrics = tf$keras$metrics$AUC(name='prc',curve='PR')
        #metrics = c('FalsePositives') # AUC, Recall,Precision,TruePositives
      )
      
      model %>% 
        fit(
          X_train, y_train, 
          epochs = 100,#100,
          validation_split = 0.3,
          class_weight = list("0"=ws_s[1],"1"=ws_s[2]),
          view_metrics = FALSE,
          verbose = 0,
          batch_size = 64
        )
      #
      Xout[irow,1]=learn_rate
      Xout[irow,2]=weight_val
      
      #model %>% evaluate(X_test, y_test)
      e=model$predict(X_train)
      predictions=unlist(apply(e, 1, function(x) which.max(x)))-1 #note don't exactly add upt to 1 so can't use >0.5 as occasionally bith just over 0.5
      actual=y_train[,2]==1
      t=table(actual,predictions)
      if (ncol(t)==1){
        j=as.integer(colnames(t))
        if (j==0){
          t=cbind(t,c(0,0))
        } else {
          t=cbind(c(0,0),t)
        }
      }
      #print(t)
      spec=t[1,1]/(sum(t[1,]))
      sens=t[2,2]/(sum(t[2,]))
      Xout[irow,3]=sens
      Xout[irow,4]=spec

      thresh=0.5
      e=model$predict(X_test)
      predictions = as.integer(e[,2]>thresh)
      #predictions=unlist(apply(e, 1, function(x) which.max(x)))-1 #note don't exactly add upt to 1 so can't use >0.5 as occasionally bith just over 0.5
      actual=y_test[,2]==1
      t=table(actual,predictions)
      if (ncol(t)==1){
        j=as.integer(colnames(t))
        if (j==0){
          t=cbind(t,c(0,0))
        } else {
          t=cbind(c(0,0),t)
        }
      }
      #print(t)
      spec=t[1,1]/(sum(t[1,]))
      sens=t[2,2]/(sum(t[2,]))
      Xout[irow,5]=sens
      Xout[irow,6]=spec
      Xout[irow,7]=thresh
      
      #cat(paste0("TEST: sensitivity = ",round(100*sens,2),"%:specificity = ",round(100*spec,2),"%"))
    }
  }
  #save_model_hdf5(model, "~/MRCmodel2020/test.h5")
  # in python
  # pip install tensorflowjs[wizard]
  # then form the command line
  # tensorflowjs_converter --input_format=keras test.h5 tfjs_model
  saveRDS(Xout,paste0(path_name,"recall_out5.RDS"))
  
}

alexanderdata=function(path_name){
  
  
  runy_model = 0 # model was saved
  # load the data
  allcombs=readRDS(paste0(path_name,"combinations_v2.rds"))
  M <- read.csv(paste0(path_name,"DB_no_red_obs_&_variables_defined_&_cleaned(b)_&_labeled(v2)_trainSetC.csv"))
  colnames(M) <- sapply(colnames(M), function(x) { sub(pattern = ".", replacement = "_", x=x, fixed=TRUE) })
  MD <- M
  L=readRDS(paste0(path_name,"dataout17April.rds"))
  Bassedata <- L$traindata
  Basselabels <- L$trainlabe
  Basse <- as.data.frame(cbind(Bassedata, Basselabels))
  colnames(Basse) <- c(L$trainvarn, "Died")
  ### Sort data by admission date
  MD_ordered <- MD[order(MD$f2date),]
  Bassedata_ordered <- Bassedata[order(MD$f2date),]
  Basselabels_ordered <- Basselabels[order(MD$f2date),]
  ### Splitting Basse into 3 and holding out one third for generalizability testing
  bfolds <- 3
  trainrows <- 1:round(nrow(Bassedata_ordered)/bfolds*(bfolds-1))
  testrows <- (round(nrow(Bassedata_ordered)/bfolds*(bfolds-1))+1):nrow(Bassedata_ordered)
  d1 <- MD_ordered$f2date[min(which(MD_ordered$f2date!=""))]; d2 <- MD_ordered$f2date[max(trainrows)]; d3 <- MD_ordered$f2date[min(testrows)]; d4 <- MD_ordered$f2date[max(testrows)]
  paste0("Training set ranges dates from ", d1, " to ", d2, " (including ", sum(MD$f2date==""), " without admission date)")
  paste0("Testing set ranges dates from ", d3, " to ", d4)
  traindata = Bassedata_ordered[trainrows,] 
  trainlabels = Basselabels_ordered[trainrows]
  testdata = Bassedata_ordered[testrows,]
  testlabels = Basselabels_ordered[testrows]
  k <- 3436                # Feature combination to use
  wts <- 1       
  j=which(allcombs[k,]==1)
  
  featnames <- L$trainvarn[j]
  traindat.df <- as.data.frame(traindata[,j]) 
  testdat.df  <- as.data.frame(testdata[ ,j])
  factorY <- as.factor(trainlabels) 
  testY <- as.factor(testlabels)
  Yfactor<- factorY
  levels(Yfactor) <- make.names(levels(Yfactor))
  levels(testY) <- make.names(levels(testY))
  train.df <- cbind(traindat.df, Yfactor)
  test.df  <- cbind(testdat.df,  Yfactor = testY)
  names <- sapply(L$trainvarn, function(x) { sub(pattern="_", replacement=".", x=x, fixed=TRUE) })
  names["age"] <- "Age"
  names(train.df) <- c(names[j], "Y")
  names(test.df) <- c(names[j], "Y")
  
  # need to be chr 0, 1 for tensorflow
  train.df$Y=as.character(train.df$Y)
  train.df$Y=gsub("X1","1",train.df$Y)
  train.df$Y=gsub("X0","0",train.df$Y)
  
  
  test.df$Y=as.character(test.df$Y)
  test.df$Y=gsub("X1","1",test.df$Y)
  test.df$Y=gsub("X0","0",test.df$Y)
  
  return(list(train=train.df,test=test.df))
  
}