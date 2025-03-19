//
//  TemplateView.swift
//  InstaThought
//
//  Created by Joe Crozier on 3/17/25.
//

import Foundation
import SwiftUI



struct TemplateView: View {
  @Binding var selectedText: String
  @Environment(\.colorScheme) var colorScheme
  @Binding var isCollapsed: Bool
  
  var body: some View {
    VStack(spacing: 0) {
      // Header
      Button(action: {
        withAnimation(.spring()) {
          isCollapsed.toggle()
        }
      }) {
        HStack {
          Text("Need inspiration?")
            .foregroundColor(.secondary)
            .font(.subheadline)
          Spacer()
          Image(systemName: isCollapsed ? "chevron.down" : "chevron.up")
            .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
      }
      
      // Templates ScrollView
      if !isCollapsed {
        ScrollView(.horizontal, showsIndicators: false) {
          LazyHStack(alignment: .top, spacing: 12) {
            ForEach(Template.defaults) { template in
              RenderViewWrapper(text: template.content, style: Style.templateStyle)
                .frame(width: 160)
                .cornerRadius(8.0)
                .background(Theme.shared.colors.accentSecondaryBackground)
                .cornerRadius(8.0)
                .onTapGesture {
                  if !isCollapsed {
                    withAnimation(.easeOut) {
                      selectedText = template.content
                      isCollapsed = true
                    }
                  }
                }
                .overlay(
                  RoundedRectangle(cornerRadius: 8.0)
                    .fill(.clear)
                    .stroke(Color.secondary, lineWidth: 1.0)
                )
            }
          }
          .padding(.horizontal, 16)
          .padding(.vertical, 12)
        }
      }
    }
    .frame(maxWidth: .infinity)
    .clipped()
    .cornerRadius(12)
    .shadow(color: colorScheme == .dark ? .white.opacity(0.03) : .black.opacity(0.05), 
            radius: 3, y: -2)
    .contentShape(Rectangle())
  }
}



struct Template: Identifiable {
  let id: UUID
  let content: String
  
  static let defaults: [Template] = [
    Template(id: UUID(), content: """
    In the quaint and curious town of Eldershire, wherein dwelt men of fine repute and most peculiar inclinations, there resided two gentlemen of singular distinction, known by the names of Mobin and Frog. These fellows, though alike in mirth and goodly disposition, were oftentimes beset by an affliction most curious and perplexing—namely, the presence of a poodle whose countenance, though of exceeding softness and fair composure, did yet deny them the gratification of such merriments as they did most covetously seek. 

    This noble beast, white as the winter’s first frost and possessed of a most sagacious aspect, did bear upon its visage a pair of cheeks most plump and ample; yet, to the dismay of our two protagonists, no mortal hand nor instrument of merriment might cause them to be clapped. Whether by nature’s cruel jest or by some enchantment most arcane, the attempt did ever prove futile, as though an unseen force did guard against the jovial designs of Mobin and Frog. Many an eve they did spend in vexation, their spirits cast low as they pondered by candle’s waning glow what artifice or stratagem might avail them in their pursuit. 

    In their despair, they did seek counsel from scholars of great renown and mendicants who claimed communion with forces unseen. One such sage, a venerable hermit of the hills, did opine that the poodle, being a beast of noble blood, was possessed of an ethereal dignity that did render it impervious to the crude whims of men. Another, a wandering minstrel, did proclaim that only by an act of true and selfless reverence might the beast’s nature be moved. Yet, neither wit nor wisdom did afford relief to our two heroes, who at length resigned themselves to their fate, sighing oft and heavy as they beheld their poodle, fair yet untouchable, a creature forever beyond the reach of mirthful applause.
    """),
    Template(id: UUID(), content: "I read the other day some verses written by an eminent painter which were original and not conventional. The soul always hears an admonition in such lines, let the subject be what it may. The sentiment they instil is of more value than any thought they may contain. To believe your own thought, to believe that what is true for you in your private heart is true for all men,––that is genius. Speak your latent conviction, and it shall be the universal sense; for the inmost in due time becomes the outmost,––and our first thought is rendered back to us by the trumpets of the Last Judgment. Familiar as the voice of the mind is to each, the highest merit we ascribe to Moses, Plato, and Milton is that they set at naught books and traditions, and spoke not what men, but what they thought. A man should learn to detect and watch that gleam of light which flashes across his mind from within, more than the lustre of the firmament of bards and sages. Yet he dismisses without notice his thought, because it is his. In every work of genius we recognize our own rejected thoughts; they come back to us with a certain alienated majesty."),
    Template(id: UUID(), content: "I went to the woods because I wished to live deliberately, to front only the essential facts of life, and see if I could not learn what it had to teach, and not, when I came to die, discover that I had not lived. I did not wish to live what was not life, living is so dear; nor did I wish to practise resignation, unless it was quite necessary. I wanted to live deep and suck out all the marrow of life, to live so sturdily and Spartan-like as to put to rout all that was not life, to cut a broad swath and shave close, to drive life into a corner, and reduce it to its lowest terms. If it proved to be mean, then why not get the whole and genuine meanness of it, and publish its meanness to the world; or if it were sublime, to know it by experience, and be able to give a true account of it. For most men, it appears to me, are in a strange uncertainty about it, whether it is of the devil or of God, and have somewhat hastily concluded that it is the chief end of man here to glorify God and enjoy him forever."),
    Template(id: UUID(), content: """
I celebrate myself, and sing myself,
             And what I assume you shall assume,
             For every atom belonging to me as good belongs to you.
             I loafe and invite my soul,
             I lean and loafe at my ease observing a spear of summer grass.
             Houses and rooms are full of perfumes, the shelves are crowded with perfumes,
             I breathe the fragrance myself and know it and like it,
             The distillation would intoxicate me also, but I shall not let it.
             The atmosphere is not a perfume, it has no taste of the distillation,
             it is odorless,
             It is for my mouth forever, I am in love with it,
             I will go to the bank by the wood and become undisguised and naked,
             I am mad for it to be in contact with me.

               The smoke of my own breath,
             Echoes, ripples, and buzzed whispers, loveroot, silkthread, crotch and vine,
             My respiration and inspiration, the beating of my heart,
             the passing of blood and air through my lungs,
             The sniff of green leaves and dry leaves, and of the shore and dark-color'd sea-rocks,
             and of hay in the barn,
             The sound of the belch'd words of my voice loos'd to the eddies of the wind.
             A few light kisses, a few embraces, a reaching around of arms,
             Play of shine and shade on the trees as the supple boughs wag,
             The delight alone or in the rush of the streets, or along the fields and hill-sides.
"""),
    Template(id: UUID(), content: """
It is a truth universally acknowledged, that a single man in possession of a good fortune, must be in want of a wife. However little known the feelings or views of such a man may be on his first entering a neighbourhood, this truth is so well fixed in the minds of the surrounding families, that he is considered as the rightful property of some one or other of their daughters.
             
             "My dear Mr. Bennet," said his lady to him one day, "have you heard that Netherfield Park is let at last?" Mr. Bennet replied that he had not. "But it is," returned she; "for Mrs. Long has just been here, and she told me all about it." Mr. Bennet made no answer. "Do you not want to know who has taken it?" cried his wife impatiently. "You want to tell me, and I have no objection to hearing it." This was invitation enough.

             "You must know, that Mrs. Long says that Netherfield is taken by a young man of large fortune from the north of England; that he came down on Monday in a chaise and four to see the place, and was so much delighted with it, that he agreed with Mr. Morris immediately; that he is to take possession before Michaelmas, and some of his servants are to be in the house by the end of next week."
"""),
    Template(id: UUID(), content: """
"There was no possibility of taking a walk that day. The cold winter wind had brought with it clouds so sombre, and a rain so penetrating, that further out-of-door exercise was now out of the question. I was glad of it: I never liked long walks, especially on chilly afternoons; dreadful to me was the coming home in the raw twilight, with nipped fingers and toes, and a heart saddened by the chidings of Bessie, the nurse, and humbled by the consciousness of my physical inferiority to Eliza, John, and Georgiana Reed.
             
             The said Eliza, John, and Georgiana were now clustered round their mama in the drawing-room: she lay reclined on a sofa by the fireside, and with her darlings about her (for the time neither quarrelling nor crying) looked perfectly happy. Me, she had dispensed from joining the group; saying, "She regretted to be under the necessity of keeping me at a distance; but that until she heard from Bessie, and could discover by her own observation, that I was endeavouring in good earnest to acquire a more sociable and childlike disposition, a more attractive and sprightly manner—something lighter, franker, more natural, as it were—she really must exclude me from privileges intended only for contented, happy little children.""
"""),
    Template(id: UUID(), content: """
             Whether I shall turn out to be the hero of my own life, or whether that station will be held by anybody else, these pages must show. To begin my life with the beginning of my life, I record that I was born (as I have been informed and believe) on a Friday, at twelve o'clock at night. It was remarked that the clock began to strike, and I began to cry, simultaneously.
             
             In consideration of the day and hour of my birth, it was declared by the nurse, and by some sage women in the neighbourhood who had taken a lively interest in me several months before there was any possibility of our becoming personally acquainted, first, that I was destined to be unlucky in life; and secondly, that I was privileged to see ghosts and spirits; both these gifts inevitably attaching, as they believed, to all unlucky infants of either gender, born towards the small hours on a Friday night. I need say nothing here, on the first head, because nothing can show better than my own conduct, whether I was destined to be unlucky or not. On the second branch of the question, I will only remark, that unless I ran through that period of my existence in a transparent case, I am a little doubtful of the evidence of my senses.
"""),
    Template(id: UUID(), content: """
You don't know about me without you have read a book by the name of The Adventures of Tom Sawyer; but that ain't no matter. That book was made by Mr. Mark Twain, and he told the truth, mainly. There was things which he stretched, but mainly he told the truth. That is nothing. I never seen anybody but lied one time or another, without it was Aunt Polly, or the widow, or maybe Mary. Aunt Polly—Tom's Aunt Polly, she is—and Mary, and the Widow Douglas is all told about in that book, which is mostly a true book, with some stretchers, as I said before.

  Now the way that the book winds up is this: Tom and me found the money that the robbers hid in the cave, and it made us rich. We got six thousand dollars apiece—all gold. It was an awful sight of money when it was piled up. Well, Judge Thatcher he took it and put it out at interest, and it fetched us a dollar a day apiece all the year round—more than a body could tell what to do with. The Widow Douglas she took me for her son, and allowed she would sivilize me; but it was rough living in the house all the time, considering how dismal regular and decent the widow was in all her ways.

"""),
    Template(id: UUID(), content: """
The studio was filled with the rich odour of roses, and when the light summer wind stirred amidst the trees of the garden, there came through the open door the heavy scent of the lilac, or the more delicate perfume of the pink-flowering thorn. From the corner of the divan of Persian saddle-bags on which he was lying, smoking, as was his custom, innumerable cigarettes, Lord Henry Wotton could just catch the gleam of the honey-sweet and honey-coloured blossoms of laburnum, whose tremulous branches seemed hardly able to bear the burden of a beauty so flamelike as theirs.

  And now and then the fantastic shadows of birds in flight flitted across the long tussore-silk curtains that were stretched in front of the huge window, producing a kind of momentary Japanese effect, and making him think of those pallid, jade-faced painters of Tokyo who, through the medium of an art that is necessarily immobile, seek to convey the sense of swift and motionless flight. The sullen murmur of the bees shouldering their way through the long unmown grass, or circling with monotonous insistence round the dusty gilt horns of the straggling woodbine, seemed to make the stillness more oppressive. The dim roar of London was like the bourdon note of a distant organ.

"""),
    Template(id: UUID(), content: """
"In the choice of books, I make no doubt that there are some which we ought wholly to discard. The smallest things are not to be despised, and what appears trifling in the general discipline of life often proves of moment in the conduct of it; but it is certain that a vast number of books only cumber our thoughts, and therefore are to be rejected. We should throw off all unnecessary lumber; books are apt to swarm beyond measure, and often but perplex rather than enlighten our understanding.
             
             I make it a point that my study should lie principally among those masters who speak the best and the most ingenuously of human actions, such as Plutarch and Seneca. Their discourses, storing themselves in my memory, shape me unawares into their own forms. They have the skill to teach, and to move the passions, and to answer in some measure the offices of friendship, by making me become better acquainted with myself and my own nature. I do not dwell among them for bare knowledge's sake, but to grow wiser and merrier, as well as more at ease in my inward man. It is an honest and a profitable pastime to amuse one's self with such pleasant discourses.
"""),
  ]
}
