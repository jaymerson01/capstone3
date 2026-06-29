class SafetyKitsProvider {
  /// Returns a localized, step-by-step list of markdown strings for Safety Action Kits
  /// mapped specifically to Barangay Moonwalk's emergency protocols.
  static List<String> getInstructionsForCategory(String category) {
    switch (category) {
      case 'Fire':
        return [
          '**Evacuate immediately** using the safest and nearest exit.',
          '**Stay low** to the ground to avoid inhaling toxic smoke.',
          '**Do not use elevators**; always use the stairs during a fire.',
          'Once outside, proceed directly to the **Moonwalk Multipurpose Hall** or your designated evacuation area.',
        ];
      case 'Flood/Typhoon':
        return [
          '**Monitor local water levels** and official Barangay Moonwalk announcements.',
          '**Turn off main electrical switches** to prevent electrocution and electrical fires.',
          '**Move critical belongings and your family** to upper floors immediately.',
          'Prepare your emergency Go-Bag and **evacuate** if ordered by authorities.',
        ];
      case 'Medical Emergency':
        return [
          '**Check for responsiveness** and ensure the victim is breathing.',
          '**Clear the immediate surroundings** to give the victim adequate space and air.',
          '**Do not move the victim** unless they are in immediate, life-threatening danger.',
          '**Wait calmly** for the Barangay rescue ambulance and professional medical personnel.',
        ];
      case 'Earthquake':
        return [
          'Execute **Duck, Cover, and Hold** immediately until the shaking stops.',
          '**Stay clear of glass windows**, falling debris, and heavy furniture.',
          '**Do not use elevators** during or immediately after the earthquake.',
          'Head safely to **open fields** or designated safe zones after the shaking entirely stops.',
        ];
      default:
        return [
          '**Stay calm** and quickly assess your immediate surroundings.',
          '**Move away** from any immediate danger, hazards, or unstable structures.',
          '**Wait for official instructions** from Barangay Moonwalk security personnel or officials.',
        ];
    }
  }
}
