import java.io.*;

public class mapSound {
  String strIndex;
  ArrayList<AudioSample> sounds;
  // Constructeur avec le premier élément
  mapSound(String name) {
    strIndex = name;
    sounds = new ArrayList<AudioSample>();
  };

  // Ajout d'un élément
  void addSound(String soundPath) {
    println("Loading " + soundPath);
    AudioSample newSound = minim.loadSample(soundPath, 512);
    if (newSound != null) { 
      sounds.add(newSound);
    } else {
      println("Impossible de charger "+soundPath);
    }
  };
  // play one of the sound with index
  void playSound() {
    int idx;
    if (sounds.size()==0) return;
    idx = (int) random(0, sounds.size());
    sounds.get(idx).trigger();
  };

  // play sound at specified index
  void playSound(int idx) {
    if (sounds.size()<idx+1) {
      println("index hors zone :"+idx);
      return;
    }
    sounds.get(idx).trigger();
  };
};

public class listeSons {
  String dirName;
  String defaultSound;
  ArrayList<mapSound> mySounds;
  // Constructeur par défaut 
  listeSons() {
    mySounds = new ArrayList<mapSound>();
  };

  // chargement des sons à partir d'un chemin de répertoire 
  void loadSounds(String dirSons) {
    dirName = dirSons;
    // Create default map sound at first index
    mapSound defaultMap = new mapSound("default");
    defaultMap.addSound(dirSons+"/default.mp3");
    mySounds.add(defaultMap);

    File dir = new File(dataPath("")+"/"+dirSons);
    println("Reading dir :"+dataPath("")+"/"+dirSons);
    //only show sound files
    String[] fileList = dir.list();

    //go through and print out all the paths
    for (int i=0; i<fileList.length; i++) {
      String name = fileList[i];
      println("file "+name);
      String[] fileParts;
      String[] nameParts;
      // Filter sound extensions
      if (!(name.endsWith("wav") || name.endsWith("mp3"))) {
        // Not a sound
        continue;
      }
      fileParts = name.split("_");
      // Check if result is non empty
      if (fileParts.length<2) {
        println("file " + name + " has no '_' for parsing");
        continue;
      }

      // nameParts = fileParts[0].split("\\");
      String index = fileParts[0]; // nameParts[nameParts.length-1];

      // Check if entry already exists
      boolean bFound = false;
      int k;
      for (k=0; k<mySounds.size(); k++) {
        if (mySounds.get(k).strIndex.compareTo(index) == 0) 
        {
          bFound = true;
          break;
        }
      }
      // If entry already exists in vector add the sound
      if (bFound == true) {
        println("ajout de "+ name +" à "+ index);
        mySounds.get(k).addSound(dirSons+"/"+name);
      } else {
        // add to vector mySounds
        println("nouvel index : "+ index+", nom : "+ name);
        mapSound newMap = new mapSound(index);
        newMap.addSound(dirSons+"/"+name);
        mySounds.add(newMap);
      }
    }
  };

  // Fonction pour renvoyer le nom d'un son 
  void playSoundName(String strNom) {
    println("recherche index : "+ strNom);
    // Check if entry already exists
    boolean bFound = false;
    for (int i=0; i<mySounds.size(); i++) {
      if (mySounds.get(i).strIndex.compareTo(strNom) == 0) 
      {
        bFound = true;
        println(" -> trouve " + mySounds.get(i).strIndex);
        mySounds.get(i).playSound();
        break;
      }
    }
    // Return result
    if (bFound == false) {
      println(" -> pas trouve (defaut)");
      mySounds.get(0).playSound();
    }
  };
};

/**
 * A class that implements the Java FileFilter interface.
 */
public class SoundFileFilter implements FileFilter
{
  private final String[] okFileExtensions = 
    new String[] {
    "wav", "mp3"
  };

  public boolean accept(File file)
  {
    for (String extension : okFileExtensions)
    {
      if (file.getName().toLowerCase().endsWith(extension))
      {
        return true;
      }
    }
    return false;
  }
}