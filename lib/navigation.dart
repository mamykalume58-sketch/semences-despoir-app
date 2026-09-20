import 'package:flutter/material.dart';

import 'data/models.dart';
import 'screens/about_screen.dart';
import 'screens/actions_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/donate_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/news_detail_screen.dart';
import 'screens/project_detail_screen.dart';
import 'screens/volunteer_screen.dart';
import 'screens/auth/login_screen.dart';

void _push(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}

void openProject(BuildContext c, Project p) => _push(c, ProjectDetailScreen(project: p));
void openDonate(BuildContext c, {String? category}) => _push(c, DonateScreen(category: category));
void openNews(BuildContext c, NewsItem n) => _push(c, NewsDetailScreen(news: n));
void openActions(BuildContext c, {String? category}) => _push(c, ActionsScreen(initialCategory: category));
void openAbout(BuildContext c) => _push(c, const AboutScreen());
void openGallery(BuildContext c) => _push(c, const GalleryScreen());
void openVolunteer(BuildContext c) => _push(c, const VolunteerScreen());
void openContact(BuildContext c) => _push(c, const ContactScreen());
void openLogin(BuildContext c) => _push(c, const LoginScreen());
