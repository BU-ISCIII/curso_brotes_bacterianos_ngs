#### How do I use Nextflow with a Singularity image?

```
nextflow
```

So, what now? In order to execute a nextflow pipeline, we need to tell it to `run` a project which contains a `main.nf` script written in groovy + the pipeline languages:

```
nextflow run /home/$USER/Documents/wgs/bacterial_wgs_training
```

Optionally, we can pass a config file, and specify the .nf script inside a project:

```
nextflow -C /home/$USER/Documents/wgs/bacterial_wgs_training/nextflow.config \
run /home/$USER/Documents/wgs/bacterial_wgs_training/main.nf
```

There is no need to download the software you want to execute, you can also execute a github repository:

```
nextflow run BU-ISCIII/bacterial_wgs_training
```

This is how we will execute the exercises during this course, so let's remove the downloaded repository to fre some space:

```
rm -rf /home/$USER/Documents/wgs/bacterial_wgs_training
```

Finally, let's ask how to use the pipeline:

```
nextflow run BU-ISCIII/bacterial_wgs_training --help
```

There is one big detail left. The software needed to execute the pipeline is no installed in our machine. Thankfully, we have a singularity image (container) ready for this course, and our pipeline has already being configurated to know where to find it and how to use it. Use the right argument and go for it:

```
nextflow run BU-ISCIII/bacterial_wgs_training -profile singularity
```
