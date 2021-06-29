
```
cd
pwd
#Output: /home/alumno
ls
```

```
cd wgs
ls
cd bacterial_wgs_training
ls
#vemos main.nf environment.yml
```

### Conda

El yml permite instalar environments de conda.

Conda es un gestor de paquetes para poder instalar software de cualquier tipo, en este caso de bioinfo.

```
cat environment.yml
#Vemos todo el software que vamos a usar en el curso
#Con el conda install -f environment.yml se nos crea un environment con todo lo que vamos a necesitar para el curso
```

```
conda env list
```

```
fastp --help
conda activate bacterial_wgs_training
#Se carga el ambiente entre parentesis delante del nombre de usuario
fastp --help
```

```
conda deactivate
conda activate nextflow
```

#### How do I use Nextflow?

```
netflow info
```

```
nextflow run bacterial_wgs_training/main.nf --help
```

Ejemplo desde github:

```
nextflow run BU-ISCIII/bacterial_wgs_training --help
```

```
#Ejemplo de un pipeline de nfcore con versiones y eso
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
